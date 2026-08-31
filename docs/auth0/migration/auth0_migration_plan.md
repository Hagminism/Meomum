# Auth0 연동 및 Supabase 마이그레이션 계획

- 상태: 제안안
- 작성일: 2026-08-25
- 입력 문서: `docs/auth_problems.md`, `docs/feedback.md`
- 대상: Flutter(Android/iOS), Riverpod, GoRouter, Supabase Database/Realtime/Storage

## 1. 결론

마이그레이션은 다음 원칙으로 진행한다.

1. Auth0는 외부 인증의 원천으로 사용한다.
2. `accounts.id`는 애플리케이션 내부의 영속 사용자 ID로 사용한다.
3. Auth0 JWT의 `sub`만 외부 Identity 식별자로 신뢰한다.
4. 이메일과 provider/connection은 계정 매핑이나 RLS 인가 키로 사용하지 않는다.
5. 실제 앱과 운영 스키마를 변경하기 전에 별도 환경에서 Auth0, Supabase RLS, Realtime, Storage PoC를 통과시킨다.
6. 운영 데이터가 없다면 새 모델로 재구성하고, 운영 데이터가 있다면 expand–migrate–contract 방식으로 이전한다.

```text
Auth0 ID Token
  sub + iss
      │
      ▼
accounts
  id UUID
  auth_issuer TEXT
  auth_subject TEXT
      │
      ├── profiles.account_id
      ├── posts.author_id
      ├── post_likes.account_id
      └── storage path ownership
```

Phase 1과 Phase 2의 PoC가 통과하지 않으면 실제 데이터베이스 및 Flutter 인증 구현으로 진행하지 않는다.

## 2. 확정할 설계 결정

### 2.1 계정 식별

- `accounts.id UUID`가 모든 도메인 데이터의 사용자 FK가 된다.
- Auth0 `sub`는 `accounts.auth_subject`에 저장한다.
- `sub`는 issuer 내부에서 유일하므로 `auth_issuer`도 함께 저장한다.
- 최종 unique key는 `(auth_issuer, auth_subject)`로 둔다.
- 현재 정책은 하나의 Auth0 Identity가 하나의 앱 계정을 구성하므로 계정 연결 기능을 구현하지 않는다.
- 나중에 하나의 계정에 여러 Identity 연결이 필요해지면 `account_identities` 테이블을 별도로 도입한다.

### 2.2 이메일과 provider

- 같은 이메일을 여러 `accounts` 행에서 허용한다.
- 이메일에는 unique 제약을 두지 않는다.
- provider 또는 Auth0 connection은 표시, 고객지원, 통계용 메타데이터다.
- provider는 PK, FK, RLS 조건으로 사용하지 않는다.
- 기존 `(user_id, provider)` 복합키는 제거한다.

### 2.3 계정 생성

- Flutter 클라이언트가 `auth_subject`를 인자로 직접 넘겨 계정을 만들 수 없게 한다.
- 인증된 요청에서 JWT의 `iss`, `sub`, connection claim을 읽는 `ensure_account()` RPC를 사용한다.
- `ensure_account()`는 인자 없이 호출하며 다음 작업을 원자적으로 수행한다.
  - JWT 검증에 필요한 claim 존재 여부 확인
  - `accounts` UPSERT
  - 최초 `profiles` INSERT
  - 내부 `account_id` 반환
- `accounts`에 대한 일반 클라이언트 INSERT/UPDATE 권한은 부여하지 않는다.

### 2.4 Storage 공개 범위

- `community-images`는 피드 표시 목적상 public-read를 유지할 수 있다.
- public-read라도 다른 계정의 업로드, 덮어쓰기, 삭제는 금지한다.
- PRD의 관계자 인증 증빙 파일은 별도의 private bucket인 `verification-documents`로 분리한다.
- Storage 경로는 외부 Auth0 `sub`가 아니라 내부 UUID를 사용한다.

```text
community-images/accounts/{account_id}/{object_id}.{extension}
verification-documents/accounts/{account_id}/{object_id}.{extension}
```

## 3. 목표 데이터 모델

최종 스키마의 개념적 형태는 다음과 같다.

```sql
create table public.accounts (
  id uuid primary key default gen_random_uuid(),
  auth_issuer text not null,
  auth_subject text not null,
  auth_connection text not null,
  email text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (auth_issuer, auth_subject)
);

create table public.profiles (
  account_id uuid primary key
    references public.accounts(id) on delete cascade,
  nickname text not null default '',
  profile_image_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- 기존 컬럼명을 최대한 유지한다.
-- posts.author_id -> accounts.id
-- post_likes.account_id -> accounts.id
```

`posts.author_id`와 `post_likes.account_id`는 `accounts.id`를 직접 참조한다. 프로필 조회는 PostgREST 중첩 관계 또는 읽기 전용 view/RPC로 제공한다.

향후 추가될 comments, reports, bookmarks, verification requests도 동일하게 `accounts.id`를 참조한다.

## 4. JWT 및 RLS 설계

### 4.1 Auth0 ID Token

Auth0 Post Login Action에서 최소한 다음 claim을 ID token에 추가한다.

```javascript
exports.onExecutePostLogin = async (event, api) => {
  api.idToken.setCustomClaim('role', 'authenticated');
  api.idToken.setCustomClaim(
    'https://meomum.app/connection',
    event.connection.name,
  );
};
```

- Supabase가 Postgres `authenticated` role을 선택하려면 literal `role: authenticated` claim이 필요하다.
- connection은 namespaced custom claim으로 둔다.
- 권위 있는 사용자 식별자는 표준 `iss`, `sub` claim이다.
- Auth0 tenant 서명 알고리즘은 Supabase Third-Party Auth가 지원하는 방식으로 설정한다. HS256 및 PS256은 사용하지 않는다.

### 4.2 Supabase Flutter client

`Supabase.initialize`의 `accessToken` 콜백에서 Auth0 Credentials Manager가 제공하는 최신 ID token을 반환한다.

```text
Supabase request
  → accessToken callback
  → Auth0 Credentials Manager
  → valid/renewed ID token
  → Data API / Realtime / Storage
```

주의사항:

- `accessToken` 콜백이 설정된 Supabase client에서는 `client.auth` namespace를 사용할 수 없다.
- 현재 코드의 `client.auth.currentUser`, `currentSession`, `onAuthStateChange`, `signOut` 사용을 모두 제거해야 한다.
- 콜백은 동시에 여러 번 호출될 수 있으므로 Credentials Manager 호출에 memoization 또는 single-flight lock을 적용한다.
- 비로그인 상태에서는 `null`을 반환한다.
- 로그아웃 시 Realtime channel을 정리하고 이후 요청이 anon 상태로 전환되는지 검증한다.

### 4.3 계정 조회 함수

RLS에서 반복적으로 Auth0 subject를 내부 UUID로 변환하는 private 함수를 둔다.

```sql
create schema if not exists private;

create or replace function private.current_account_id()
returns uuid
language sql
stable
security definer
set search_path = ''
as $$
  select a.id
  from public.accounts as a
  where a.auth_issuer = (select auth.jwt() ->> 'iss')
    and a.auth_subject = (select auth.jwt() ->> 'sub')
  limit 1
$$;
```

구현 시 다음 보안 설정을 포함한다.

- 함수의 `search_path`를 빈 값으로 고정하고 객체 이름을 schema-qualified로 작성한다.
- `PUBLIC`의 실행 권한을 회수한다.
- 필요한 role에만 schema usage와 function execute 권한을 부여한다.
- `ensure_account()`만 계정 생성 권한을 가지게 한다.
- RLS 테스트에서 함수가 없는 계정에 대해 `NULL`을 반환하고 모든 소유자 작업을 거부하는지 확인한다.

### 4.4 정책 패턴

소유자 컬럼에는 내부 UUID를 저장하고 다음 패턴을 사용한다.

```sql
with check ((select private.current_account_id()) = author_id)

using ((select private.current_account_id()) = author_id)
with check ((select private.current_account_id()) = author_id)
```

UPDATE 정책에는 `USING`뿐 아니라 `WITH CHECK`도 넣어 소유자 ID 변경을 차단한다.

INSERT 시 클라이언트가 사용자 ID를 전달하지 않아도 되도록 가능한 컬럼에는 `private.current_account_id()`를 default로 사용한다. RLS 검증은 별도로 유지한다.

Storage 쓰기 정책은 경로의 내부 UUID와 `current_account_id()`를 비교한다. `upsert`를 사용하므로 INSERT뿐 아니라 SELECT와 UPDATE 정책도 검증한다.

## 5. 단계별 실행 계획

### Phase 0 — 사전 점검 및 경로 결정

목표: 운영 데이터 유무와 실제 마이그레이션 방식을 확정한다.

작업:

1. Supabase 원격 프로젝트에 사용자, profile, post, like, Storage object가 있는지 확인한다.
2. 스키마와 데이터를 백업하고 별도 프로젝트에서 복구 시험을 수행한다.
3. 현재 migration 003–006이 어느 환경에 적용됐는지 기록한다.
4. 다음 두 경로 중 하나를 선택한다.
   - 가치 있는 운영 데이터 없음: greenfield reset
   - 운영 데이터 있음: expand–migrate–contract
5. 개발용 Auth0 tenant와 별도 Supabase staging 프로젝트를 만든다.
6. Auth0 domain/client ID, callback URL 등 환경별 설정 관리 방법을 확정한다.

완료 조건:

- 백업 복구가 성공한다.
- greenfield 또는 production 경로가 명시적으로 결정된다.
- 실제 운영 프로젝트는 Phase 1–2 동안 변경하지 않는다.

### Phase 1 — Auth0 자체 PoC

목표: 같은 이메일의 세 소셜 Identity가 서로 다른 Auth0 계정이 되는지 검증한다.

작업:

1. Auth0 Native Application을 만든다.
2. Android package `com.salmyeosi.meomum.meomum`과 iOS bundle identifier에 맞는 callback/logout URL을 등록한다.
3. Google standard social connection을 구성한다.
4. Kakao 및 Naver Custom Social Connection을 구성한다.
   - Authorization URL
   - Token URL
   - Scope
   - Fetch User Profile Script
   - provider의 immutable user ID를 Auth0 `user_id`로 반환
5. Post Login Action을 추가한다.
6. 앱의 Google/Kakao/Naver 버튼이 각각 지정된 Auth0 connection으로 이동하게 한다.
7. 동일한 이메일을 가진 세 provider 계정으로 로그인한다.
8. Auth0 Dashboard 및 ID token을 확인한다.

검증 항목:

- 서로 다른 `sub`가 3개 생성된다.
- 로그아웃 후 다른 provider로 로그인해도 이전 Auth0 계정으로 자동 연결되지 않는다.
- 각 token의 `iss`, `sub`, `role`, connection claim이 예상과 일치한다.
- Kakao/Naver 프로필의 nickname, email, picture mapping이 정상이다.
- Google의 기존 native UX가 Auth0 browser/Universal Login으로 바뀌는 것이 제품 UX상 수용 가능한지 확인한다.

중단 조건:

- 같은 이메일의 Identity가 의도하지 않게 연결된다.
- Custom Social Connection에서 안정적인 immutable user ID를 얻을 수 없다.
- 필요한 모바일 로그인 UX를 충족하지 못한다.

### Phase 2 — Auth0 JWT와 Supabase PoC

목표: 실제 앱 스키마와 분리된 scratch 리소스에서 인증·인가 경로 전체를 증명한다.

작업:

1. staging Supabase 프로젝트의 Third-Party Auth에 Auth0 tenant를 등록한다.
2. Flutter spike 또는 최소 샘플 앱에서 `Supabase.initialize(accessToken: ...)`를 구성한다.
3. scratch accounts/table과 전용 test bucket을 만든다.
4. `auth.jwt()`로 `iss`, `sub`, `role`, connection을 확인하는 진단 RPC를 만든다.
5. 두 Auth0 사용자 A/B로 Database CRUD를 시험한다.
6. Realtime subscribe 및 token refresh 이후 재연결을 시험한다.
7. Storage upload, overwrite, download, delete를 시험한다.
8. A token으로 B의 row와 object에 접근하는 음수 테스트를 수행한다.

완료 조건:

- Data API의 SELECT/INSERT/UPDATE/DELETE가 예상대로 동작한다.
- `role=authenticated`가 적용된다.
- token refresh 이후에도 요청과 Realtime이 정상이다.
- A가 B의 쓰기 및 삭제 작업을 수행할 수 없다.
- Storage public/private 정책이 계획대로 동작한다.

이 단계가 끝날 때까지 기존 Flutter AuthDataSource와 운영 migration은 변경하지 않는다.

### Phase 3 — 새 계정 모델과 RLS 기반 구현

목표: staging에서 최종 `accounts` 보안 경계를 구현한다.

작업:

1. 신규 migration을 추가한다. 적용된 기존 migration 003–006을 직접 수정하지 않는다.
2. `accounts`와 새 `profiles` 구조를 만든다.
3. `private.current_account_id()`와 `ensure_account()`를 구현한다.
4. profiles, posts, post_likes에 대한 새 FK와 RLS를 작성한다.
5. Storage path 및 정책을 내부 `account_id` 기준으로 작성한다.
6. 계정 A/B 및 비로그인 사용자의 정책 테스트를 자동화한다.
7. `ensure_account()` 동시 호출 시 중복 계정이 생성되지 않는지 검증한다.

완료 조건:

- 계정 생성은 오직 서명된 JWT subject를 통해서만 가능하다.
- provider 또는 email 값을 변조해도 다른 계정에 접근할 수 없다.
- 모든 소유권 정책에 양수/음수 테스트가 존재한다.
- `accounts.auth_subject`를 일반 클라이언트가 변경할 수 없다.

### Phase 4 — 데이터 마이그레이션

### 경로 A: 운영 데이터가 없는 경우

권장 경로다.

1. staging에서 migration 전체 reset을 반복 실행한다.
2. 003–006의 레거시 스키마를 007 이후 migration이 최종 계정 모델로 변환하도록 먼저 만든다.
3. 앱과 migration이 안정화되면 첫 운영 배포 전에 migration을 clean baseline으로 squash한다.
4. Supabase Auth 테스트 사용자는 폐기하고 Auth0 계정으로 다시 생성한다.

### 경로 B: 운영 데이터가 있는 경우

expand–migrate–contract를 사용한다.

Expand:

1. `accounts`와 임시 `legacy_account_map`을 추가한다.
2. 기존 `(profiles.user_id, profiles.provider)`마다 새로운 `account_id`를 발급한다.
3. posts에 nullable `author_account_id`를 추가한다.
4. post_likes에 nullable `account_id`를 추가한다.
5. 레거시 컬럼과 정책은 유지해 기존 앱을 계속 지원한다.

Migrate:

1. posts는 `(author_id, author_provider)`로 임시 map을 조회해 backfill한다.
2. post_likes는 `(user_id, provider)`로 backfill한다.
3. Storage object 경로 또는 별도 ownership map을 내부 account UUID로 이전한다.
4. 기존 계정과 Auth0 계정 연결은 다음 중 검증된 방법으로만 수행한다.
   - provider의 immutable identity ID를 양쪽에서 검증
   - 기존 Supabase 인증과 새 Auth0 인증을 모두 완료하는 dual-proof migration flow
5. 이메일만으로는 절대 자동 연결하지 않는다.
6. 행 수, 고아 FK, NULL, 중복, 소유권 checksum을 비교한다.

Contract:

1. 새 앱의 안정화와 롤백 기간이 끝난 후 시작한다.
2. 새 account 컬럼을 NOT NULL로 바꾼다.
3. 새 FK와 RLS만 활성화한다.
4. 레거시 provider 복합 FK 및 컬럼을 제거한다.
5. `auth.users` FK와 신규 가입 trigger를 제거한다.
6. 임시 migration map은 감사용 export 후 제거한다.

미매핑 계정은 자동 병합하지 않고 명시적인 재인증 또는 고객지원 대상으로 남긴다.

### Phase 5 — Flutter 애플리케이션 전환

목표: Repository–DataSource 상위 구조는 유지하면서 인증 구현과 상태 모델을 교체한다.

### 5.1 패키지 및 플랫폼 설정

- `auth0_flutter`를 추가한다.
- 로그인 용도의 `google_sign_in`은 Auth0 전환 후 제거한다. 다른 기능에서 사용 중인지 먼저 검색한다.
- Auth0 provider secret은 Flutter `.env`나 번들에 넣지 않는다.
- Flutter에는 Auth0 domain과 client ID 같은 public configuration만 둔다.
- Android manifest/Gradle 및 iOS Info.plist/Associated Domains를 Auth0 callback 요구사항에 맞춘다.
- 기존 `meomum://login-callback`은 Supabase Auth용이므로 Auth0 callback 정책에 맞게 교체한다.

### 5.2 인증 도메인 모델

현재 동기식 `isSignedIn` 중심 인터페이스를 비동기 세션 모델로 바꾼다.

```text
AuthSessionStatus
  initializing
  authenticated
  unauthenticated
```

권장 인터페이스:

```text
AuthDataSource
  restoreSession()
  signInWithOAuth(provider)
  signOut()
  getCurrentCredentials()
  getIdToken()

AuthRepository
  위 기능을 Result/도메인 모델로 변환

AuthSessionController (Riverpod AsyncNotifier)
  startup credential 복원
  ensure_account 호출
  current account UUID 보관
  GoRouter refresh 유도
```

### 5.3 현재 코드별 변경

- `pubspec.yaml`
  - `auth0_flutter` 추가
  - 로그인 용도 `google_sign_in` 제거 검토
- `lib/main.dart`
  - Auth0 client/token provider 준비
  - `Supabase.initialize(accessToken: ...)` 연결
- `lib/di/di.dart`
  - Auth0 client provider
  - concurrency-safe token provider
  - CurrentAccount provider 추가
- `lib/core/data/data_source/auth/auth_data_source_impl.dart`
  - Supabase Auth 및 GoogleSignIn 의존 제거
  - Auth0 login/logout/CredentialsManager 구현
- `lib/core/domain/enum/auth_session_status.dart`
  - 초기화 상태 추가 및 명칭 정리
- `lib/core/routing/router.dart`
  - Async 인증 초기화 중 redirect 보류
  - authenticated/unauthenticated 상태 기반 redirect
- `lib/core/routing/go_router_refresh_stream.dart`
  - Supabase auth stream 대신 Riverpod 인증 상태 notifier에 연결
- `lib/core/data/dto/user/user_dto.dart`
  - Supabase `User` 타입 의존 제거
  - Auth0 UserProfile 또는 앱 AuthSession DTO 사용
- `lib/core/data/data_source/community/community_post_data_source_impl.dart`
  - 모든 `client.auth.currentUser` 사용 제거
  - CurrentAccount의 UUID 사용
  - provider 필드 전송 제거

### 5.4 세션 시나리오 테스트

- 최초 로그인
- 사용자가 로그인 창을 취소
- 앱 재시작 후 credential 복원
- ID token 만료 직전/직후 API 요청
- refresh token 만료
- 로그아웃 후 Supabase 요청이 anon으로 처리되는지 확인
- 로그인 계정 교체
- Android login 도중 process death 및 credential recovery
- iOS callback 및 logout callback
- 네트워크 단절 중 refresh 후 복구
- Realtime channel이 사용자 변경 후 이전 token을 계속 사용하지 않는지 확인

### Phase 6 — Cutover 및 레거시 정리

배포 순서:

1. Auth0 tenant, connections, Action을 배포한다.
2. backward-compatible database migration을 먼저 배포한다.
3. staging RLS 및 Storage 회귀 테스트를 실행한다.
4. Auth0 지원 앱을 feature flag 또는 환경별 build로 배포한다.
5. 내부 사용자부터 점진 활성화한다.
6. 로그인 성공률과 API/Storage 오류를 확인한 후 전체 활성화한다.
7. 롤백 기간이 끝나면 contract migration을 실행한다.

모니터링 항목:

- provider별 로그인 성공/취소/실패율
- Credentials Manager refresh 실패
- Supabase 401/403 및 RLS 거부율
- `ensure_account()` 실패 및 중복 충돌
- Realtime 인증/재연결 오류
- Storage upload/update/delete 오류
- 미매핑 legacy 계정 수

로그에 ID token, refresh token 또는 provider access token을 기록하지 않는다.

정리 작업:

- 앱에서 Supabase Auth 로그인 코드를 제거한다.
- Supabase Dashboard의 기존 Social Auth provider를 비활성화한다.
- `auth.users` 기반 trigger와 FK를 제거한다.
- `author_provider`, `profiles.provider`, `post_likes.provider`를 제거한다.
- 사용하지 않는 Google 로그인 client 설정과 deep link를 정리한다.
- Auth0 계정 삭제와 Supabase account 삭제를 함께 수행하는 backend/Edge Function 흐름을 만든다.

## 6. RLS 및 Storage 테스트 매트릭스

최소 다음 테스트를 자동화한다.

### accounts

- A는 자신의 account ID를 조회할 수 있다.
- A는 B의 private account metadata를 조회하거나 변경할 수 없다.
- A는 `auth_subject`, `auth_issuer`, connection을 변경할 수 없다.
- 비로그인 사용자는 account provisioning을 호출할 수 없다.

### profiles

- 공개 프로필 필드는 정책에 따라 조회할 수 있다.
- A는 자신의 profile만 수정할 수 있다.
- A가 payload의 account ID를 B로 바꿔도 INSERT/UPDATE가 거부된다.

### posts

- 인증된 사용자는 피드를 조회할 수 있다.
- A는 자신의 post만 생성, 수정, 삭제할 수 있다.
- A가 `author_id=B`로 INSERT하면 거부된다.
- UPDATE로 `author_id`를 A에서 B로 바꾸면 거부된다.

### post_likes

- A는 자신의 like만 생성, 삭제할 수 있다.
- A가 B를 대신해 like를 생성하거나 삭제할 수 없다.

### community-images

- public-read 정책이면 누구나 URL을 읽을 수 있다.
- A는 자신의 UUID 경로에만 업로드할 수 있다.
- A는 B의 object를 overwrite 또는 delete할 수 없다.
- upsert에 필요한 SELECT/UPDATE 정책까지 검증한다.

### verification-documents

- bucket은 private이다.
- A는 자신의 파일만 읽고 쓸 수 있다.
- B는 A의 파일을 읽을 수 없다.
- 관리자 승인 역할은 별도의 DB 권한 모델로 검증한다.

## 7. Gate와 중단 조건

### Gate 0 — 백업

- 원격 데이터 유무 파악
- 백업 복구 성공
- migration 경로 승인

### Gate 1 — Auth0 Identity 분리

- 동일 이메일, 세 provider, 서로 다른 `sub`
- 각 connection의 profile mapping 성공

### Gate 2 — Supabase 전체 제품 연동

- Database CRUD 성공
- Realtime 성공
- Storage 성공
- cross-account 음수 테스트 성공

### Gate 3 — 새 스키마

- `accounts` provisioning 성공
- RLS 자동 테스트 성공
- provider/email 변조 우회 불가

### Gate 4 — 데이터 정합성

- row count 및 ownership checksum 일치
- 고아 FK와 예상 밖 NULL 없음
- legacy 미매핑 계정 처리 방안 확정

### Gate 5 — Flutter 회귀

- Android/iOS 세션 시나리오 통과
- 로그인 화면 깜빡임 및 redirect loop 없음
- 계정 교체 후 이전 사용자 데이터가 노출되지 않음

다음 중 하나라도 발생하면 cutover를 중단한다.

- 세 provider의 Identity가 의도와 다르게 연결됨
- `role` 또는 `sub` claim 누락
- A가 B 소유 데이터에 쓰기/삭제 성공
- Storage 소유권 우회
- token refresh 후 Data API 또는 Realtime 지속 실패
- 기존 데이터 소유권을 이메일로만 추정해야 하는 상황

## 8. 롤백 전략

- contract migration 전에는 기존 컬럼과 Supabase Auth 흐름을 유지한다.
- 앱의 feature flag를 Supabase Auth로 되돌릴 수 있게 한다.
- 새 `accounts` 데이터와 backfill 컬럼은 롤백 시 삭제하지 않고 진단을 위해 보존한다.
- Auth0 connection/Action 변경은 이전 배포 버전을 별도로 보관한다.
- 데이터 migration은 재실행 가능하고 멱등적으로 작성한다.
- destructive cleanup은 관찰 기간과 백업 복구 재시험 후에만 수행한다.

## 9. 권장 작업 단위

변경은 다음 순서로 분리하면 검토와 롤백이 쉽다.

1. Auth0/Supabase isolated PoC와 테스트 문서
2. `accounts` 스키마, helper function, RLS 테스트
3. profiles/posts/likes additive migration 및 backfill 검증
4. Storage 경로·정책 migration
5. Flutter Auth0 DataSource와 token provider
6. Riverpod AuthSession과 GoRouter 전환
7. Community DataSource의 CurrentAccount 전환
8. Android/iOS 설정 및 통합 테스트
9. cutover 관찰성 및 feature flag
10. 레거시 Supabase Auth/provider 컬럼 cleanup

## 10. 첫 실행 범위

실제 구현을 시작할 때 첫 작업은 Phase 1–2만 수행한다.

첫 번째 구현 결과물:

- Auth0 개발 tenant의 Google/Kakao/Naver connection
- Post Login Action
- 최소 Flutter 인증 spike
- Supabase staging Third-Party Auth 설정
- scratch table 및 bucket RLS
- 동일 이메일 3계정 증명 결과
- A/B Database·Realtime·Storage 접근 테스트 결과

이 결과가 승인된 뒤에만 본 프로젝트의 SQL migration과 AuthDataSource 변경을 시작한다.
