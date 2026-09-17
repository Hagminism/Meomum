# 커뮤니티 댓글 및 지도 검색 구현 정리

> 작성일: 2026-09-17
>
> 대상 브랜치: `feature/community`

이 문서는 커뮤니티 댓글 기능과 지도 검색 기능의 최초 구현 및 후속 보정 내용을 정리한 문서다. 상세 요구사항은 각 기능의 요구사항 문서를 기준으로 하며, 이 문서는 실제 구현 결과와 현재의 제품 결정을 기록한다.

## 관련 요구사항

- [커뮤니티 댓글 요구사항](community/comment/requirements.md)
- [지도 검색 요구사항](map/map_search/requirements.md)
- [Design Pipeline](../ui/design_pipeline_kr.md)

## 1. 커뮤니티 댓글

### 구현 범위

- 게시글 상세 화면에서 댓글 작성
  - 텍스트 입력
  - 선택적 이미지 첨부
  - 댓글 작성 중 로딩 및 중복 요청 방지
- 댓글 목록 표시
  - 프로필 이미지
  - 닉네임과 작성 시간
  - 거주 지역
  - 게시글 작성자 표시
  - 댓글 좋아요
- 댓글 메뉴
  - 수정
  - 삭제
  - 신고
- 댓글 수정
  - 댓글 본문 영역을 입력 폼으로 전환
  - 저장 중 입력과 취소·저장 액션 비활성화
- 댓글 삭제
  - 확인 다이얼로그 표시
  - 댓글 행은 제거하지 않고 삭제된 댓글 문구로 치환
  - 댓글 이미지가 있으면 Storage 정리 큐에 등록
- 대댓글
  - 본댓글에만 작성 가능
  - 대댓글은 본댓글 하위에 같은 들여쓰기 수준으로 표시
  - 대댓글에 다시 답글을 작성해도 동일한 대댓글 수준을 유지
- 마이페이지의 `내가 쓴 댓글` 탭
  - 본댓글과 사용자가 작성한 대댓글을 모두 표시

### 대댓글 조회 보정

내가 작성한 댓글을 조회할 때, 사용자가 작성한 대댓글의 본댓글이 다른 사용자의 댓글이면 기존 그룹화 과정에서 대댓글이 누락될 수 있었다. 현재는 본댓글 작성자와 관계없이 사용자가 작성한 대댓글을 결과에 보존한다.

관련 코드:

- [`community_comment_repository_impl.dart`](../../lib/core/data/repository/community/community_comment_repository_impl.dart)
- [`community_comment_repository_impl_test.dart`](../../test/core/data/repository/community/community_comment_repository_impl_test.dart)
- [`my_page_detail_comment_list.dart`](../../lib/feature/my_page_detail/presentation/component/my_page_detail_comment_list.dart)

### 댓글 입력 및 답글 작성 UI

기존 게시글 상세 화면의 디자인 언어를 유지하면서, 댓글 화면에 필요한 상태만 별도 컴포넌트로 구성했다.

- 댓글 프로필 헤더는 게시글 헤더의 닉네임·지역·시간 배치를 따름
- 점 세 개 메뉴는 댓글 프로필 행과 세로 중앙을 맞춤
- 메뉴 배경은 앱 화면과 어울리는 흰색으로 고정
- 검색 결과 매장은 상세 화면이 준비되지 않았으므로 `InkWell`의 터치 피드백만 제공
- 답글 작성 상태는 [`CommunityCommentReplyIndicator`](../../lib/feature/community/presentation/component/comment/community_comment_reply_indicator.dart)로 공통화
- 답글 작성 상태의 취소 액션은 기본 Material `TextButton` 대신 앱 색상과 44px 터치 영역을 사용
- 댓글 제출 중에는 입력창과 답글 취소 액션을 비활성화

댓글 목록과 수정 폼은 다음 컴포넌트에서 관리한다.

- [`community_comment_list.dart`](../../lib/feature/community/presentation/component/comment/community_comment_list.dart)
- [`community_comment_edit_form.dart`](../../lib/feature/community/presentation/component/comment/community_comment_edit_form.dart)
- [`community_post_detail_comment_input.dart`](../../lib/feature/community_post_detail/presentation/component/community_post_detail_comment_input.dart)
- [`home_post_detail_comment_input.dart`](../../lib/feature/home_post_detail/presentation/component/home_post_detail_comment_input.dart)

### 댓글 수 집계 정책

게시글의 댓글 수는 화면에 현재 보이는 댓글 수가 아니라 `comments` 테이블의 전체 행 수로 산정한다. 따라서 삭제된 본댓글과 삭제된 대댓글도 게시글 댓글 수에 포함한다.

적용 내용:

1. 기존 게시글의 `posts.comment_count`를 댓글 전체 행 수로 보정
2. 댓글 생성 시 `comment_count`를 1 증가
3. 댓글 삭제 시 댓글 행은 soft delete 처리하고 `comment_count`는 감소시키지 않음
4. 댓글 삭제 성공 후 클라이언트에서 댓글 수를 임의로 차감하지 않음

관련 마이그레이션:

- [`20260917055320_add_comments.sql`](../../supabase/migrations/20260917055320_add_comments.sql)
- [`20260917072232_include_deleted_comment_count.sql`](../../supabase/migrations/20260917072232_include_deleted_comment_count.sql)

삭제 처리는 `is_deleted`, `deleted_at`을 갱신하고 본문을 `삭제된 댓글입니다.`로 변경한다. 이미지가 연결되어 있었다면 Storage 파일 삭제를 즉시 수행하지 않고 정리 큐에 등록한다.

## 2. 지도 검색

### 지도 하단 Drawer

- 지도 진입 또는 위치 재검색 후 주변 매장을 하단 Drawer에 표시
- `get_nearby_stores` RPC를 통해 반경 내 매장 조회
- 거리 기준 오름차순으로 표시
- 카테고리 필터칩으로 표시 매장 필터링
- `가까운 매장이 먼저 표시됩니다.` 안내 문구 표시
- 로딩·빈 결과 상태 제공
- 매장 항목은 상세 정보 연동 전까지 터치 피드백만 제공

관련 컴포넌트:

- [`map_bottom_drawer_sheet.dart`](../../lib/feature/map/presentation/component/drawer/map_bottom_drawer_sheet.dart)
- [`map_store_list_item.dart`](../../lib/feature/map/presentation/component/drawer/map_store_list_item.dart)

### 장소 검색 화면

- feature 경로: `/feature/map_search`
- 지도 하위 중첩 경로: `/map/map-search`
- 상단 검색창에서 상호명·지점명·주소 검색
- 사용자 주변 반경으로 제한하지 않고 전체 매장 대상 검색
- 검색창 입력 중 300ms debounce 적용
- 이전 요청의 응답이 최신 검색 결과를 덮어쓰지 않도록 요청 세대 번호를 검증
- 검색 실행 전·후 로딩 상태 제공
- 결과 없음·오류·재시도 상태 제공

관련 코드:

- [`map_search_screen.dart`](../../lib/feature/map_search/presentation/screen/map_search_screen.dart)
- [`map_search_view_model.dart`](../../lib/feature/map_search/presentation/screen/map_search_view_model.dart)
- [`map_search_result_item.dart`](../../lib/feature/map_search/presentation/component/map_search_result_item.dart)
- [`commercial_store_data_source_impl.dart`](../../lib/core/data/data_source/commercial_store/commercial_store_data_source_impl.dart)
- [`router.dart`](../../lib/core/routing/router.dart)

### 장소 검색 RPC

- RPC: `search_commercial_stores(p_query)`
- 입력값을 trim한 후 빈 문자열은 검색하지 않음
- 상호명·지점명·주소 검색을 DB에서 수행
- 네트워크·타임아웃 요청은 기존 데이터 소스의 재시도 정책을 따름

관련 마이그레이션:

- [`20260917000000_add_commercial_store_search.sql`](../../supabase/migrations/20260917000000_add_commercial_store_search.sql)

## 3. 화면 이동 및 상태 안전성

- 댓글 작성 또는 삭제가 진행 중일 때 게시글 상세 화면의 뒤로가기를 막아 요청 중 화면 이탈을 방지
- 답글 작성 취소는 댓글 내용과 답글 대상 상태를 함께 초기화
- 댓글 수정·삭제·작성 상태는 각 게시글 상세 ViewModel에서 관리
- 홈 게시글 상세와 커뮤니티 게시글 상세의 댓글 입력 경험을 동일하게 유지

## 4. 검증 결과

### Flutter

- `dart format --output=none --set-exit-if-changed`: 통과
- `flutter analyze`: 통과, `No issues found!`
- `flutter test`: 전체 27개 통과

주요 검증 항목:

- 내가 쓴 댓글 조회에서 다른 사용자의 본댓글에 달린 내 대댓글 보존
- 지도 검색 debounce 및 오래된 응답 무시
- 검색 결과 매장의 터치 피드백
- 댓글 수정 저장 중 입력·액션 비활성화
- 게시글 작성자 여부에 따른 댓글 메뉴 노출

### Supabase

- 연결된 원격 프로젝트에 댓글 수 집계 보정 마이그레이션 적용
- `supabase db push --dry-run --linked --yes`: 적용할 변경 사항 없음(`upToDate`)
- 댓글 전체 행 수와 `posts.comment_count` 비교 검증 결과 불일치 게시글 0건

Supabase advisor와 lint에서는 이번 변경과 무관한 기존 PostGIS 함수, RLS, search path, 인덱스 관련 경고·오류가 확인되었다. 별도 정비 과제로 분리한다.

## 5. 현재 보류한 항목

- 댓글·대댓글 실시간 갱신은 후속 작업으로 보류
- 매장 검색 결과를 누른 뒤 이동할 매장 상세 화면은 상세 정보 조회 방식이 확정되지 않아 보류
- 따라서 현재 매장 목록 항목의 `onTap`에는 별도 화면 이동 동작을 넣지 않음
- 매장 상세 정보 조회 방식과 데이터 계약이 정해지면 지도 Drawer와 장소 검색 결과에 동일한 상세 이동을 연결

## 6. 주요 커밋

| 커밋 | 내용 |
| --- | --- |
| `8d54ba0` | 지도 검색 및 주변 매장 목록 구현 |
| `da1cde2` | 지도 검색 중첩 라우트 연결 |
| `758bcf1` | 댓글 기능 구현 |
| `d7cabc8` | 댓글 UI 테마 및 편집 상태 개선 |
| `7353bf7` | 댓글 리스트 레이아웃 및 수정 폼 개선 |
| `e69b4bf` | 댓글 작성·삭제 중 뒤로가기 방지 강화 |
| `f0f2b8c` | 마이페이지에 작성한 대댓글 표시 |
| `02f8dde` | 삭제 댓글을 게시글 댓글 수에 포함 |
| `2d12e7d` | 답글 작성 상태 입력 UI 개선 |
| `a322241` | 답글 작성 인디케이터 UI 수정 |
