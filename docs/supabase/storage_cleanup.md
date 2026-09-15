# 회원 탈퇴 및 정리 작업 운영

## 1. 문서 목적

회원 탈퇴와 이미지 삭제는 한 번의 데이터베이스 작업만으로 끝나지 않습니다.

- PostgreSQL에는 계정, 프로필, 게시글, 좋아요와 이미지 메타데이터가 저장됩니다.
- Supabase Storage에는 실제 프로필·게시글 이미지 파일이 저장됩니다.
- Auth0에는 로그인에 사용하는 외부 사용자 정보가 저장됩니다.

PostgreSQL 작업은 트랜잭션으로 묶을 수 있지만, Storage와 Auth0 API 호출은 PostgreSQL 트랜잭션에 포함할 수 없습니다. 따라서 앱 데이터는 먼저 안전하게 삭제하고, 외부 시스템 정리는 작업 큐와 서버 Worker를 통해 성공할 때까지 재시도합니다.

## 2. 현재 구현 상태

현재 저장소에는 Storage 정리와 Auth0를 포함한 앱 계정 삭제를 위한 코드와 migration이 작성되어 있습니다. 다만 다음 작업은 아직 운영 환경에 적용되지 않았습니다.

- `20260914040601_storage_cleanup_and_account_deletion.sql` migration 적용
- `storage-cleanup` Edge Function 배포
- Storage 정리용 Supabase Cron 등록
- Auth0 Management API용 M2M 애플리케이션 설정
- `delete-account`, `auth0-cleanup` Edge Function 배포
- Auth0 삭제용 Cron 등록

따라서 migration과 Edge Function을 운영 환경에 적용하기 전까지는 현재 배포된 앱에서 Auth0 콘솔의 사용자가 삭제되지 않습니다. 소스 기준 최종 구조는 이 문서의 이후 내용과 같습니다.

## 3. 용어 정리

| 용어 | 의미 |
| --- | --- |
| 작업 큐 | 아직 끝나지 않은 삭제 작업을 저장하는 테이블 |
| Worker | 큐의 작업을 읽고 실제 삭제를 수행하는 Edge Function |
| Cron Job | Worker를 정해진 주기마다 호출하는 스케줄러 |
| `storage-cleanup` | Storage 파일 삭제 Worker |
| `auth0-cleanup` | Auth0 사용자 삭제 Worker |
| `delete-account` | 사용자의 탈퇴 요청을 받아 최초 삭제를 시작하는 Edge Function |

Worker는 Auth0 안에 만들어지는 기능이 아닙니다. Supabase에 만든 Edge Function을 Worker로 사용하는 것입니다.

## 4. 회원 탈퇴 전체 흐름

구현한 최종 구조에서는 Flutter가 DB RPC를 직접 호출하지 않고, 회원 탈퇴용 Edge Function을 호출합니다.

```text
사용자가 회원 탈퇴 확인
        ↓
Flutter가 delete-account Edge Function에 POST
        ↓
요청자의 Auth0 JWT 검증
        ↓
DB 트랜잭션 시작
  ├─ Auth0 삭제 작업 등록
  ├─ 프로필·게시글 이미지 Storage 작업 등록
  ├─ accounts 삭제
  └─ profiles·posts·post_likes CASCADE 삭제
        ↓
DB 커밋
        ↓
Auth0 Management API로 사용자 삭제 시도
        ├─ 성공: Auth0 작업 완료 처리
        └─ 실패: Auth0 삭제 큐에 남김
                ↓
            Cron이 auth0-cleanup Worker 호출
                ↓
            Auth0 삭제 재시도
        ↓
Flutter Auth0 로그아웃 및 로컬 credential 삭제
        ↓
로그인 화면으로 이동
```

## 5. 요청 권한과 Auth0 삭제 권한

삭제 요청에는 두 종류의 권한 확인이 필요합니다.

### 5.1 사용자가 본인 계정을 삭제하는지 확인

Edge Function은 요청에 포함된 Auth0 JWT를 검증합니다.

- 서명이 Auth0에서 발급되었는지 확인
- `iss`, `sub`, `aud`, `exp` 확인
- JWT의 `iss`와 `sub`가 `accounts.auth_issuer`, `accounts.auth_subject`와 일치하는지 확인
- 클라이언트가 전달한 임의의 사용자 ID는 신뢰하지 않음

이 검증으로 사용자는 자신의 계정만 삭제할 수 있습니다.

### 5.2 서버가 Auth0 사용자를 삭제할 권한 확인

Auth0 콘솔에서 계정 삭제 전용 Machine-to-Machine 애플리케이션을 만듭니다.

- 대상 API: `Auth0 Management API`
- 필요한 권한: `delete:users`
- Client Secret: Supabase Edge Function Secret에만 저장

Edge Function은 Client Credentials 방식으로 Management API 토큰을 발급받은 뒤 다음 API를 호출합니다.

```text
DELETE https://{auth0-domain}/api/v2/users/{url-encoded-auth0-user-id}
```

M2M Client Secret은 Flutter 앱이나 저장소에 포함하지 않습니다. Auth0 Management API는 `delete:users` 권한을 가진 애플리케이션만 사용자를 삭제할 수 있습니다.

참고: [Auth0 사용자 관리](https://auth0.com/docs/manage-users/user-accounts/manage-users-using-the-management-api), [Management API 토큰](https://auth0.com/docs/secure/tokens/access-tokens/management-api-access-tokens/get-management-api-access-tokens-for-production)

## 6. DB 트랜잭션과 실패 처리

`delete_account()` RPC에서 수행하는 DB 작업은 하나의 PostgreSQL 함수 실행 단위로 처리합니다.

```text
Storage 이미지 경로를 큐에 등록
        +
Auth0 삭제 작업을 큐에 등록
        +
accounts 삭제
        ↓
모두 성공하면 커밋
하나라도 DB 오류가 나면 전체 롤백
```

`accounts` 삭제에는 다음과 같은 연결 데이터 삭제가 포함됩니다.

- `profiles`
- `posts`
- `post_likes`
- `post_images`

DB 작업 중 오류가 발생하면 계정과 큐 등록이 모두 원래 상태로 돌아갑니다. 별도의 `BEGIN`·`COMMIT`을 함수 안에 작성하지 않아도 PostgreSQL 함수 호출 자체가 하나의 트랜잭션으로 실행됩니다.

다만 Storage와 Auth0는 외부 시스템이므로 다음 작업은 DB 트랜잭션으로 되돌릴 수 없습니다.

```text
DB 삭제 성공
  ↓
Storage 또는 Auth0 삭제 실패
  ↓
DB 데이터를 복구하지 않음
  ↓
실패한 외부 작업을 큐에 남기고 재시도
```

즉, DB 오류는 롤백되지만 Storage·Auth0 API 오류는 보상 작업과 재시도로 처리합니다.

## 7. Storage 정리 큐

### 7.1 큐가 필요한 이유

PostgreSQL의 이미지 메타데이터와 Storage의 실제 파일은 서로 다른 저장 공간에 있습니다.

예를 들어 게시글에서 이미지 A를 삭제할 때 다음 두 작업이 필요합니다.

1. `post_images`에서 이미지 A의 메타데이터 삭제
2. Storage에서 이미지 A의 실제 파일 삭제

두 작업을 하나의 PostgreSQL 트랜잭션으로 묶을 수 없으므로, 실제 파일 삭제가 실패해도 나중에 다시 처리할 수 있도록 큐에 경로를 저장합니다.

### 7.2 Storage 작업이 큐에 들어가는 경우

```text
게시글 작성 중 일부 이미지 업로드 후 실패
  → 이미 업로드된 파일을 큐에 등록

게시글 수정으로 기존 이미지 제거
  → 제거된 이미지 경로를 DB 트랜잭션 안에서 큐에 등록

게시글 삭제
  → 게시글 이미지 경로를 큐에 등록한 뒤 게시글 삭제

프로필 이미지 변경
  → 기존 프로필 이미지 또는 새로 업로드했지만 저장하지 못한 이미지 등록

회원 탈퇴
  → 프로필·게시글 이미지 전체를 큐에 등록한 뒤 계정 삭제
```

### 7.3 `storage_cleanup_queue`의 상태

큐에는 완료 여부를 나타내는 별도의 `completed` 컬럼을 두지 않습니다.

| 상태 | 의미 |
| --- | --- |
| 행이 존재하고 `next_retry_at`이 지남 | 지금 처리할 수 있는 작업 |
| 행이 존재하고 `next_retry_at`이 아직 지나지 않음 | 다음 재시도 시간 대기 |
| 행이 삭제됨 | Storage 삭제와 완료 처리가 끝남 |

주요 컬럼은 다음과 같습니다.

| 컬럼 | 설명 |
| --- | --- |
| `account_id` | 작업을 만든 계정. 회원 탈퇴 후에는 `NULL`이 될 수 있음 |
| `bucket_id` | `community-images` 또는 `profile-images` |
| `storage_path` | 삭제할 Storage 파일 경로 |
| `attempt_count` | 작업을 선점한 횟수 |
| `last_error` | 최근 실패 메시지 |
| `next_retry_at` | 다음 처리 가능 시간 |
| `lease_until` | Worker가 작업을 선점한 만료 시간 |

회원 탈퇴로 `accounts`가 삭제되어도 외래 키는 `ON DELETE SET NULL`로 동작하므로 큐 항목은 보존됩니다. 따라서 로그인 세션이 사라진 뒤에도 서버가 파일을 삭제할 수 있습니다.

## 8. Storage Worker와 Cron 흐름

```text
Supabase Cron
  ↓ 5분마다 POST
storage-cleanup Edge Function
  ↓
최대 50개 작업 선점
  ↓
버킷별로 Storage 파일 삭제
  ├─ 성공: 큐 항목 삭제
  └─ 실패: 오류와 다음 재시도 시간 기록
```

`lease_until`과 `FOR UPDATE SKIP LOCKED`를 사용해 여러 실행이 같은 작업을 동시에 처리하지 않도록 합니다.

재시도 간격은 다음과 같습니다.

| 선점 후 실패 횟수 | 다음 재시도 |
| ---: | ---: |
| 1회 | 1분 후 |
| 2회 | 10분 후 |
| 3회 | 1시간 후 |
| 4회 이상 | 24시간 후 |

최대 시도 횟수로 영구 중단하지 않고, 계속 실패하면 24시간 간격으로 재시도합니다.

## 9. Auth0 삭제 큐와 Worker

Storage 큐에는 `bucket_id`와 `storage_path`가 필요하지만, Auth0 삭제에는 Auth0의 `user_id`가 필요합니다. 서로 다른 외부 시스템과 작업 데이터를 하나의 큐에 섞지 않기 위해 Auth0 삭제 큐를 별도로 둡니다.

예상 테이블은 다음과 같습니다.

```text
auth0_user_deletion_queue
- id
- auth_issuer
- auth_subject             -- Auth0 user_id
- account_id               -- 탈퇴 후 NULL 가능
- attempt_count
- last_error
- next_retry_at
- lease_until
- completed_at
- created_at
```

`completed_at`이 비어 있으면 재시도 대상이고, 값이 있으면 Auth0 삭제가 완료된 상태입니다. 완료된 행은 삭제하지 않고 Auth0 `issuer`·`subject`만 tombstone으로 보존합니다. `ensure_account()`는 삭제 작업이 진행 중이거나 삭제 완료 시각 이전에 발급된 JWT는 차단하지만, 삭제 완료 이후 새로 발급된 JWT는 허용합니다. 따라서 기존 토큰으로 계정이 되살아나는 문제는 막으면서, 사용자가 같은 소셜 계정으로 새 계정을 다시 만들 수 있습니다.

Auth0 삭제 Worker의 흐름은 다음과 같습니다.

```text
Supabase Cron
  ↓ 5분마다 POST
auth0-cleanup Edge Function
  ↓
Auth0 삭제 큐에서 처리 대상 조회
  ↓
M2M Client Credentials로 Management API 토큰 발급
  ↓
DELETE /api/v2/users/{user_id}
  ├─ 204: 삭제 성공 → 완료 표시
  ├─ 404: 이미 삭제된 사용자 → 성공으로 처리하고 완료 표시
  ├─ 429·5xx·네트워크 오류: 재시도 예약
  └─ 401·403: 권한 또는 Secret 설정 오류 기록
```

Auth0 삭제가 실패해도 이미 삭제된 DB 데이터를 되살리지는 않습니다. Auth0 사용자 삭제를 성공할 때까지 큐에서 재시도하는 방식입니다.

## 10. Worker와 Cron의 관계

Worker와 Cron은 같은 기능이 아닙니다.

```text
Cron Job = 정해진 시간에 HTTP POST를 보내는 알람
Worker   = POST를 받고 큐의 실제 삭제 작업을 수행하는 Edge Function
Queue    = 아직 처리되지 않은 삭제 작업 목록
```

권장 구성은 다음과 같습니다.

- `storage-cleanup` Worker + Storage 정리 Cron
- `auth0-cleanup` Worker + Auth0 정리 Cron

Cron 하나가 직접 Auth0 사용자를 삭제하는 것이 아닙니다. Cron은 `auth0-cleanup` 함수를 호출하고, 함수가 Management API를 사용해 삭제합니다.

## 11. Cron 실행 부담

5분 주기로 Worker 하나를 실행하면 다음과 같습니다.

```text
시간당 12회
하루 288회
30일 약 8,640회
```

Storage Worker와 Auth0 Worker를 각각 실행해도 월 약 17,280회입니다. 현재 Supabase 공식 기준 Edge Function 호출량은 Free 요금제 월 500,000회, Pro 요금제 월 2,000,000회가 포함되어 있어 이 정도 주기의 호출은 일반적인 소규모 서비스에서 부담이 낮습니다.

각 실행은 큐가 비어 있으면 즉시 종료하고, 한 번에 여러 작업을 처리합니다. 따라서 사용자마다 별도의 Cron을 만들지 않고 Worker별 Cron 하나만 운영합니다.

요금과 할당량은 변경될 수 있으므로 실제 운영 전 Supabase 사용량 화면을 확인합니다.

참고: [Supabase Edge Function 사용량](https://supabase.com/docs/guides/platform/manage-your-usage/edge-function-invocations), [Supabase Cron](https://supabase.com/docs/guides/cron)

## 12. 보안 원칙

- Flutter에는 Auth0 M2M Client Secret이나 Supabase `service_role` key를 포함하지 않습니다.
- Auth0 Management API 토큰은 서버에서 Client Credentials 방식으로 발급합니다.
- Auth0 삭제 대상은 검증된 JWT 또는 DB의 `auth_subject`에서 결정합니다.
- 클라이언트가 전달한 Auth0 사용자 ID를 그대로 삭제 API에 사용하지 않습니다.
- Storage 큐 등록은 `accounts/{현재 계정 ID}/...` 경로만 허용합니다.
- Storage 큐 선점·완료·실패 처리는 service role을 사용하는 서버 Worker만 수행합니다.
- JWT, Client Secret, Management API 토큰, 사용자 개인정보를 로그에 남기지 않습니다.
- Auth0 삭제 요청은 인증된 사용자 본인 계정에만 허용합니다.

## 13. 적용 순서

현재 migration이 아직 적용되지 않았으므로 다음 순서로 진행합니다.

1. 기존 Storage migration에 Auth0 삭제 큐와 `delete_account` 변경 사항을 반영합니다.
2. staging Supabase에 migration을 적용합니다.
3. 테이블, 외래 키, RLS, RPC 권한과 트랜잭션 동작을 확인합니다.
4. Auth0 콘솔에 전용 M2M 애플리케이션을 만들고 `delete:users` 권한을 부여합니다.
5. Auth0 domain, M2M Client ID, Client Secret을 Edge Function Secret으로 등록합니다.
6. `delete-account`와 `auth0-cleanup` Edge Function을 배포합니다.
7. `storage-cleanup`과 `auth0-cleanup`을 각각 5분 주기로 호출하는 Cron Job을 등록합니다.
8. 정상 삭제·DB 롤백·Storage 실패 재시도·Auth0 실패 재시도 시나리오를 검증합니다.
9. 검증이 끝난 뒤 운영 Supabase에 migration과 함수를 적용합니다.

## 14. 검증 시나리오

- DB 작업 중 오류가 발생하면 계정과 큐 등록이 모두 롤백되는지 확인
- 회원 탈퇴 후 `accounts`, `profiles`, `posts`, `post_likes`가 삭제되는지 확인
- 회원 탈퇴 후 프로필·게시글 이미지가 Storage 큐에 남는지 확인
- Storage 삭제 성공 시 큐 항목이 제거되는지 확인
- Storage 삭제 실패 시 재시도 시간이 갱신되는지 확인
- Auth0 삭제 성공 후 Auth0 콘솔에서 사용자가 사라지는지 확인
- Auth0 `404`를 이미 삭제된 상태로 처리하는지 확인
- Auth0 `429`, `5xx`, 네트워크 오류가 재시도되는지 확인
- Auth0 `401`, `403`이 권한 설정 오류로 기록되는지 확인
- 탈퇴 후 기존 토큰으로 앱 데이터를 조회할 수 없는지 확인
- Flutter와 저장소에 M2M Secret과 service role key가 없는지 확인

## 15. 적용 시 필요한 Secret과 Cron

Edge Function Secret에는 다음 값을 등록합니다.

| Secret | 용도 |
| --- | --- |
| `AUTH0_DOMAIN` | Auth0 tenant domain 및 issuer 검증 |
| `AUTH0_CLIENT_ID` | Flutter가 사용하는 Auth0 애플리케이션의 JWT audience 검증 |
| `AUTH0_M2M_CLIENT_ID` | Management API Client Credentials 발급 |
| `AUTH0_M2M_CLIENT_SECRET` | Management API Client Credentials 발급 |
| `AUTH0_MANAGEMENT_API_AUDIENCE` | 기본값은 `https://{AUTH0_DOMAIN}/api/v2/` |
| `STORAGE_CLEANUP_CRON_SECRET` | Storage Worker 호출 검증 |
| `AUTH0_CLEANUP_CRON_SECRET` | Auth0 Worker 호출 검증 |

M2M Client Secret과 `service_role` key는 Flutter 앱·Git 저장소·로그에 넣지 않습니다. Auth0 M2M 애플리케이션에는 `Auth0 Management API`의 `delete:users` 권한만 부여합니다.

Cron은 migration에 실제 Secret이나 프로젝트 URL을 넣어 자동 등록하지 않습니다. 운영 Supabase에서 pg_cron 또는 Supabase Cron으로 다음 두 함수를 각각 5분마다 호출하고, 요청 헤더에 대응하는 Secret을 전달합니다.

```text
POST /functions/v1/storage-cleanup
x-storage-cleanup-secret: <STORAGE_CLEANUP_CRON_SECRET>

POST /functions/v1/auth0-cleanup
x-auth0-cleanup-secret: <AUTH0_CLEANUP_CRON_SECRET>
```

Supabase Cron을 SQL로 등록할 때는 Secret을 SQL에 평문으로 작성하지 말고 Vault에 저장해 `pg_net` 요청에서 읽도록 합니다. Dashboard에서 Cron을 등록하는 경우에도 동일한 헤더 Secret을 사용합니다.

## 16. 관련 구현 위치

- DB 테이블 및 RPC: `supabase/migrations/20260914040601_storage_cleanup_and_account_deletion.sql`
- Storage 큐 등록 계약: `lib/core/domain/repository/storage_cleanup/storage_cleanup_repository.dart`
- Storage 큐 등록 구현: `lib/core/data/data_source/storage_cleanup/storage_cleanup_data_source_impl.dart`
- Storage Worker: `supabase/functions/storage-cleanup/index.ts`
- 회원 탈퇴 진입점: `supabase/functions/delete-account/index.ts`
- Auth0 삭제 Worker: `supabase/functions/auth0-cleanup/index.ts`
- Supabase Function 설정: `supabase/config.toml`
- Storage 운영 안내: `docs/feature/community/edit_post/image_cleanup_queue.md`

Auth0 삭제 큐와 두 Auth0 Edge Function은 소스에 구현되어 있으며, migration 적용·Secret 등록·배포·Cron 등록 후 운영 동작을 검증해야 합니다.
