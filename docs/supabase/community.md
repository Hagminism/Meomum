# 커뮤니티 RPC 및 데이터 흐름

## `create_post_with_images(...)`

게시글 본문과 이미지 메타데이터를 하나의 DB 트랜잭션으로 저장하는 RPC다.

호출 위치:

- [`community_post_data_source_impl.dart`](../../lib/core/data/data_source/community/community_post_data_source_impl.dart)

### 전체 흐름

```text
사용자가 제목·본문·이미지 입력
    ↓
이미지를 Storage에 accounts/{accountId}/ 경로로 업로드
    ↓
create_post_with_images()
    ↓
current_account_id()로 작성자 확인
    ↓
입력값 및 이미지 경로 검증
    ↓
posts INSERT
    ↓
post_images INSERT
    ↓
게시글 UUID 반환
    ↓
게시글 상세 재조회
    ↓
커뮤니티 목록 최상단에 반영
```

### 주요 입력값

- `p_upper_region`, `p_lower_region`: 게시 지역
- `p_category`: 게시판 카테고리
- `p_title`: 제목
- `p_content`: 본문
- `p_images`: Storage 경로·공개 URL·정렬 순서를 담은 JSON 배열
- `p_place_*`: 선택한 장소 정보

### RPC 내부 검증

- 현재 인증된 계정이 존재하는지 확인
- 지역·제목·본문의 필수 입력 확인
- 제목 50자 이하 확인
- 본문 10,000자 이하 확인
- 이미지 최대 10개 확인
- 이미지 경로가 현재 계정의 `accounts/{accountId}/` 하위인지 확인

### Storage 실패 보상 처리

Storage는 PostgreSQL 트랜잭션에 포함되지 않으므로 애플리케이션에서 보상 삭제를 수행한다.

```text
이미지 업로드 중 실패
    ↓
이미 업로드된 파일 삭제
    ↓
이미지 업로드 실패 메시지 표시
```

```text
이미지 업로드 성공
    ↓
DB RPC 실패
    ↓
posts/post_images는 DB 트랜잭션으로 롤백
    ↓
업로드된 Storage 파일 삭제
```

정의:

- [`012_create_post_images_and_rpc.sql`](../../supabase/migrations/012_create_post_images_and_rpc.sql)

## 게시글 목록 조회

목록 조회 자체는 RPC가 아니라 PostgREST 테이블 조회를 사용한다.

```text
posts 조회
    ├─ profiles: 작성자 닉네임·프로필 이미지
    ├─ post_images: 이미지 URL·정렬 순서
    └─ post_likes: 현재 사용자의 좋아요 여부
```

현재 데이터 소스는 지역·생성일 기준으로 게시글을 조회하고, 앱에서 카테고리 필터를 적용한다.

## 좋아요 처리

현재 좋아요에는 별도 RPC가 없다.

```text
post_likes INSERT 또는 DELETE
    ↓
posts.like_count 조회
    ↓
posts.like_count UPDATE
```

따라서 동시 요청에서 좋아요 수가 어긋날 수 있으며, 추후 `toggle_post_like()` RPC로 행 변경과 카운트 갱신을 하나의 트랜잭션으로 묶는 개선이 필요하다.

## 권한 및 RLS

커뮤니티 테이블은 `authenticated` 역할에만 필요한 테이블 권한을 부여한다.

- `posts`: SELECT, UPDATE
- `profiles`: SELECT
- `post_images`: SELECT
- `post_likes`: SELECT, INSERT, DELETE

권한 정의:

- [`013_grant_community_table_permissions.sql`](../../supabase/migrations/013_grant_community_table_permissions.sql)

테이블 권한과 별개로 RLS 정책이 적용되며, 게시글 작성자는 RPC 내부의 `current_account_id()`로 결정한다.
