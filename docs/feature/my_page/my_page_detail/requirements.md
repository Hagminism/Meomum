# MyPageDetail 화면 구현

## 1. 연결 채널

TalkToFigma mcp를 통해 디자인을 가져옵니다. 연결 채널은 ugzokzd9.

## 2. 구현 요구사항

- 디렉터리 구성은 다음과 같이 정한다.
    - 루트의 feature 디렉터리 하위에 별도의 feature 2개를 추가로 구성한다.
    - 마이페이지: /feature/my_page(이미 정의되어있음)
    - 마이페이지 상세(피드): /feature/my_page_detail
    - 프로필 편집 페이지: /feature/edit_profile
- 마이페이지 하위 화면 경로는 다음과 같이 정한다.
    - 마이페이지: /my-page(이미 정의되어있음)
    - 마이페이지 상세(피드): /my-page/feed
    - 프로필 편집 페이지: /my-page/feed/edit-profile
    - 마이페이지 상세와 프로필 편집 페이지는 마이페이지 하위 중첩 라우트로 설계한다.
- 마이페이지 상세 페이지는 아래 링크의 피그마 컴포넌트의 디자인을 따른다.
    - https://www.figma.com/design/7a81lvN3BOxOTBtC65JBap/2026-%EA%B4%80%EA%B4%91%EB%8D%B0%EC%9D%B4%ED%84%B0-%ED%99%9C%EC%9A%A9-%EA%B3%B5%EB%AA%A8%EC%A0%84?node-id=405-4825&t=3NOWn549OlsxuGmN-4
- 마이페이지 화면 상단에 위치한 카드를 눌렀을 때 마이페이지 상세 페이지로 이동해야한다.
- 상세 페이지 상단 앱바는 기존에 정의한 위젯을 재사용한다.
    - [custom_app_bar.dart](/Users/ihagmin/Meomum/lib/core/presentation/component/custom_app_bar.dart)
    - optional 파라미터의 추가가 필요한 경우 nullable로 선언하여 사용한다.
- 화면 상단에는 마이페이지 상단에 위치하던 카드의 내용을 borderless + colorless 상태 그대로 배치한다.
- 프로필 편집 버튼을 누를 경우 프로필 편집 페이지로 이동해야한다.
    - 프로필 편집 화면의 경우, 온보딩 플로우 중 프로필 생성 화면의 UI 구성을 재사용한다.
        - [create_profile_screen.dart](/Users/ihagmin/Meomum/lib/feature/on_boarding/feature/create_profile/presentation/screen/create_profile_screen.dart)
    - 단, 같은 UI를 갖추되 /feature/edit_profile/presentation 경로에 별도의 파일을 만들어 사용해야하며, 상단의 문구는 프로필 편집 화면에 맞게
      수정해야한다.
- 화면 중단부에 위치한 카테고리 스위치는 버튼을 누를 때마다 자연스러운 애니메이션을 보여주어야한다.
- 화면 하단에는 카테고리에 맞는 게시글 목록을 표시한다.
    - 이때 기존에 정의해놓은 post card 위젯을 재사용한다. 이 경우, 파일을 별도 생성하지 않고 기존 파일을 가져다 쓴다.
        - [community_post_card.dart](/Users/ihagmin/Meomum/lib/feature/community/presentation/component/post/community_post_card.dart)