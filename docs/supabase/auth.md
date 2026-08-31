# 인증 RPC

## 1. `ensure_account()`

Auth0 로그인 또는 저장된 세션 복원 직후 호출한다. Auth0 사용자와 Meomum 내부 계정을 연결하고, 앱에서 사용할 내부 계정 UUID를 반환한다.

호출 위치:

- [`auth_data_source_impl.dart`](../../lib/core/data/data_source/auth/auth_data_source_impl.dart)

### 호출 흐름

```text
Auth0 로그인 또는 세션 복원
    ↓
Auth0 ID Token을 Supabase 요청에 전달
    ↓
ensure_account()
    ↓
JWT의 iss, sub 검증
    ↓
accounts 생성 또는 갱신
    ↓
profiles 생성 또는 안전한 표시명 보정
    ↓
accounts.id 반환
```

### 수행 내용

1. `auth.jwt()`에서 `iss`, `sub`를 읽는다.
2. 두 값이 없으면 요청을 거부한다.
3. `(auth_issuer, auth_subject)` 조합으로 `accounts`를 찾는다.
4. 신규 계정이면 `accounts`를 생성하고, 기존 계정이면 이메일·connection·수정 시각을 갱신한다.
5. `profiles`를 생성한다.
6. 기존 닉네임이 비어 있거나 `사용자`, 이메일 또는 이메일 로컬 파트인 경우에만 새 표시명으로 보정한다.
7. 내부 `accounts.id`를 반환한다.

최신 정의는 [`011_correct_email_local_part_nicknames.sql`](../../supabase/migrations/011_correct_email_local_part_nicknames.sql)에 있다. `007`, `009`, `010`, `011` migration에서 같은 함수가 단계적으로 보정되었으며, 실제로는 마지막 정의가 적용된다.

## 2. `current_account_id()`

현재 인증된 JWT의 `iss`, `sub`와 일치하는 `accounts.id`를 반환하는 보조 함수다.

```text
현재 JWT
    ↓
iss + sub 추출
    ↓
accounts.auth_issuer + auth_subject 조회
    ↓
accounts.id 반환
```

앱에서 직접 호출하지 않고 다음 위치에서 사용한다.

- `create_post_with_images()`의 게시글 작성자 결정
- `accounts`, `profiles`, `posts`, `post_likes` RLS 정책
- Storage 파일 경로의 계정 소유권 검증

따라서 클라이언트가 전달한 `author_id`를 신뢰하지 않고, 요청의 인증 토큰으로 작성자를 결정한다.

## 권한

- `ensure_account()`: `authenticated`에 실행 권한 부여
- `current_account_id()`: `authenticated`에 실행 권한 부여
- 두 함수 모두 `SECURITY DEFINER`로 동작한다.

관련 정의:

- [`007_replace_supabase_auth_with_auth0_accounts.sql`](../../supabase/migrations/007_replace_supabase_auth_with_auth0_accounts.sql)
