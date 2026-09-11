# Supabase RPC 및 DB 함수

현재 Meomum에서 Supabase를 통해 사용하는 RPC와 DB 함수를 feature별로 정리한 문서다.

## 문서 기준

- 원격 Supabase migration은 로컬 migration과 동일한 최신 상태다.
- 앱에서 직접 호출하는 RPC는 `ensure_account()`, `get_nearby_stores()`, `create_post_with_images()`다.
- `current_account_id()`는 인증된 사용자의 내부 계정 UUID를 조회하는 보조 함수다.
- `update_commercial_store_location()`은 앱이 직접 호출하지 않는 상가 좌표 Trigger 함수다.
- `handle_new_user()`는 Supabase Auth 시절의 레거시 함수이며 Auth0 전환 과정에서 제거된 구조다.

## Feature별 문서

- [인증](auth.md)
- [지도](map.md)
- [커뮤니티](community.md)

## 공통 보안 원칙

1. 클라이언트에서 Auth0의 `sub` 또는 내부 `accounts.id`를 작성자 식별자로 전달하지 않는다.
2. Supabase는 Auth0 ID Token의 검증된 `iss`, `sub`를 기반으로 현재 계정을 식별한다.
3. 테이블 접근은 PostgreSQL 권한(`GRANT`)과 RLS 정책을 함께 사용한다.
4. 커뮤니티 테이블은 `authenticated` 역할에만 접근 권한을 부여하며 `anon`에는 공개하지 않는다.
5. 게시글 작성 RPC는 `SECURITY DEFINER`로 실행되지만, 함수 내부에서 현재 계정과 이미지 경로를 다시 검증한다.

## 적용 migration

- [`007_replace_supabase_auth_with_auth0_accounts.sql`](../../supabase/migrations/007_replace_supabase_auth_with_auth0_accounts.sql): Auth0 계정 모델, 인증 보조 함수, RLS
- [`011_correct_email_local_part_nicknames.sql`](../../supabase/migrations/011_correct_email_local_part_nicknames.sql): 최신 `ensure_account()` 보정
- [`012_create_post_images_and_rpc.sql`](../../supabase/migrations/012_create_post_images_and_rpc.sql): `post_images`와 게시글 작성 RPC
- [`013_grant_community_table_permissions.sql`](../../supabase/migrations/013_grant_community_table_permissions.sql): 커뮤니티 테이블 권한
