# 머뭄 (Meomum)

<table>
  <td><img width="512" height="512" alt="로고(R값 x)_waifu2x_noise0_scale4x (1)" src="https://github.com/user-attachments/assets/8a630115-f018-409e-8b0c-7a85945b83ce" /></td>
  <td><img width="850" height="500" alt="로그인 (2)" src="https://github.com/user-attachments/assets/c25f548e-33a0-43c4-97aa-9d418ff0ea8b" /></td>
</table>





### 낯선 동네에서도, 잠깐의 여행이 생활이 되도록.

머뭄은 한 달 살기, 워케이션, 단기 체류를 시작한 사람들이 낯선 지역에 조금 더 쉽게 머물 수 있도록 돕는 앱입니다.

관광지만 둘러보고 떠나는 대신, 그 동네의 맛집과 생활 정보, 사람들의 이야기를 발견하고 서로 연결될 수 있는 경험을 만들고 있습니다.

## 머뭄에서 할 수 있는 일

- **홈**: 사진이 있는 지역 콘텐츠를 둘러보며 새로운 동네를 발견합니다.
- **커뮤니티**: 지역별 게시판에서 생활 정보와 질문을 나누고, 직접 글을 작성합니다.
- **동네지도**: 지도에서 주변 상가와 생활 인프라를 찾아봅니다.
- **나의 여행**: 프로필과 내가 작성한 글을 관리합니다.
- **게시글 작성·수정**: 사진과 위치를 함께 올리고, 작성한 글을 다시 수정할 수 있습니다.

지금은 커뮤니티를 중심으로 서비스를 만들어가고 있습니다. 앞으로는 숙소, 일자리, 대여공간처럼 실제 체류에 필요한 정보까지 한곳에서 만날 수 있도록 확장할 예정입니다.

## 왜 만들고 있나요?

낯선 지역에 오래 머물러 보면 관광 정보만으로는 부족한 순간이 많습니다.

어디에서 장을 보면 좋은지, 동네 사람들은 어떤 곳을 좋아하는지, 잠깐 머무는 사람도 편하게 질문할 수 있는 곳은 어디인지 알기 어렵습니다.

머뭄은 이런 작은 궁금증과 막막함을 지역의 정보와 사람으로 풀어내려 합니다. 잠깐 머무는 사람도 그 동네의 생활에 자연스럽게 스며들 수 있도록요.

## 기술 스택

- Flutter / Dart
- Riverpod
- GoRouter
- Supabase Database, Storage, RPC, RLS
- Auth0
- Naver Map 및 Search API
- Freezed / JSON Serializable / Build Runner

MVVM 기반 Clean Architecture를 바탕으로 구성하고, 사용자 액션은 MVI 방식으로 처리합니다.

```text
lib
├── core       # 공통 데이터, 도메인, UI, 라우팅
├── feature    # 기능별 화면과 상태 관리
├── di         # 의존성 주입
└── ui         # 앱 색상과 디자인 시스템

supabase      # DB migration 및 Supabase 스크립트
docs          # 제품 요구사항과 기술 문서
test          # 테스트 코드
```

## 시작하기

### 필요한 환경

- Flutter SDK
- Dart SDK `^3.12.2`
- iOS 개발 시 Xcode
- Android 개발 시 Android Studio
- Supabase 프로젝트
- Auth0 프로젝트

### 의존성 설치

```bash
flutter pub get
```

### 환경 변수 설정

프로젝트 루트에 `.env` 파일을 만들고 로컬 개발에 필요한 값을 입력합니다.

```env
SUPABASE_URL=
SUPABASE_ANON_KEY=
GOOGLE_WEB_CLIENT_ID=
GOOGLE_IOS_CLIENT_ID=
NAVER_MAP_CLIENT_ID=
SMALL_BUSINESS_API_SERVICE_KEY=
NAVER_SEARCH_CLIENT_ID=
NAVER_SEARCH_CLIENT_SECRET=
```

`.env`에는 인증 정보와 API 키가 포함될 수 있으므로 저장소에 커밋하지 않습니다. 공개 가능한 설정과 비밀 키의 관리 방법은 배포 환경에 맞게 분리해야 합니다.

Auth0의 Domain과 Client ID는 [`auth0_config.dart`](lib/core/auth/auth0_config.dart)에서 관리합니다.

### 앱 실행

```bash
flutter run
```

## 개발 명령어

Freezed 또는 JSON Serializable 코드가 변경된 경우:

```bash
dart run build_runner build --delete-conflicting-outputs
```

코드 분석과 테스트:

```bash
flutter analyze
flutter test
```

Supabase migration을 CLI로 적용하는 경우:

```bash
supabase db push
```

## 문서

- [제품 요구사항](docs/PRD.md)
- [기술 스택](docs/tech_stack.md)
- [개발 컨벤션](docs/convention.md)
- [인증 세션 흐름](docs/auth0/auth_session_flow.md)
- [Supabase 문서](docs/supabase/README.md)
- [게시글 수정 이미지 정리 큐](docs/feature/community/edit_post/image_cleanup_queue.md)

## 아직 만들어가는 중입니다

머뭄은 완성된 서비스라기보다, 지역에 머무는 사람에게 정말 필요한 경험이 무엇인지 하나씩 확인하며 만들어가는 프로젝트입니다.

작은 동네 정보 하나가 누군가에게는 새로운 하루를 시작하는 데 도움이 될 수 있다고 믿습니다.
