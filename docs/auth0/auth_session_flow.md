# 인증 상태 및 앱 진입 플로우

## 1. 문서 목적

인증 상태 변경 이후의 Auth0 인증, Supabase 프로필 조회, 온보딩 진입, 라우팅 흐름을 정리합니다.

기존에는 `AuthDataSource`가 인증과 프로필 처리를 함께 담당했지만, 현재는 각 계층의 책임을 분리해 관리합니다.

```text
AuthDataSource
  └─ Auth0 인증과 인증 식별자 처리

ProfileRepository
  └─ profiles 테이블과 프로필 이미지 처리

AuthRepository
  └─ 인증 결과와 프로필을 조합하고 앱 사용자 상태 관리

AuthSessionController
  └─ 인증 상태 변화를 화면과 라우터에 전달
```

## 2. 계층별 책임

### AuthDataSource

[`auth_data_source.dart`](../../lib/core/data/data_source/auth/auth_data_source.dart)

Auth0와 직접 통신하고 인증 식별자를 생성합니다.

- 소셜 로그인 진행
- 저장된 Auth0 세션 복원
- Auth0 로그아웃
- `ensure_account` RPC 호출
- Auth0 사용자 정보를 `AuthIdentity`로 변환

`AuthDataSource`는 `ProfileRepository`를 의존하지 않습니다.

### ProfileRepository

[`profile_repository_impl.dart`](../../lib/core/data/repository/profile/profile_repository_impl.dart)

Supabase의 프로필 데이터와 Storage를 관리합니다.

- 프로필 조회
- 닉네임 수정
- 거주 지역 수정
- 프로필 이미지 업로드
- 기존 프로필 이미지 삭제

### AuthRepository

[`auth_repository_impl.dart`](../../lib/core/data/repository/auth/auth_repository_impl.dart)

인증 식별자와 프로필 정보를 조합해 앱에서 사용하는 `User`를 생성합니다.

```text
AuthIdentity + Profile = User
```

다음 상태도 관리합니다.

- 현재 로그인 사용자
- 로그인 여부
- 세션 상태
- 세션 복원 오류 메시지
- 프로필 및 지역 수정 결과

### AuthSessionController

[`auth_session_controller.dart`](../../lib/core/presentation/service/auth_session_controller.dart)

`AuthRepository`의 인증 상태 스트림을 한 곳에서 구독하고 `Listenable` 형태로 전달합니다.

화면과 라우터가 각각 인증 스트림을 직접 구독하지 않도록 하여 인증 상태의 관리 지점을 하나로 통합합니다.

## 3. 앱 시작 흐름

```text
앱 실행
  ↓
GoRouter 생성
  ↓
AuthSessionController 생성
  ↓
AuthRepository가 세션 복원 시작
  ↓
Splash 화면 표시
  ↓
Auth0 자격 증명 확인
  ↓
ensure_account RPC 호출
  ↓
profiles 조회
  ↓
AuthIdentity와 Profile을 User로 조합
  ↓
인증 상태 결정
  ↓
라우터가 다음 화면으로 이동
```

앱 시작 직후에는 세션 상태가 `initializing`입니다.

## 4. 세션 복원 결과별 이동

### 로그인 정보가 없는 경우

```text
Auth0 자격 증명 없음
  ↓
signedOut
  ↓
로그인 화면
```

### 세션 복원에 성공한 경우

```text
Auth0 자격 증명 복원
  ↓
accounts와 profiles 조회
  ↓
signedIn
  ↓
지역 선택 여부 확인
```

지역 선택 여부에 따라 다음 화면으로 이동합니다.

```text
지역 미선택 → 온보딩 화면
지역 선택 완료 → 홈 화면
```

### 세션 복원 중 오류가 발생한 경우

```text
세션 복원 오류
  ↓
error
  ↓
Splash 재시도 화면
```

## 5. 소셜 로그인 흐름

```text
로그인 버튼 선택
  ↓
AuthRepository.signInWithOAuth()
  ↓
AuthDataSource가 Auth0 로그인 진행
  ↓
ensure_account RPC 호출
  ↓
AuthIdentity 반환
  ↓
ProfileRepository가 profiles 조회
  ↓
User 생성
  ↓
signedIn 상태 전달
  ↓
지역 선택 여부에 따라 온보딩 또는 홈 이동
```

프로필이 아직 완성되지 않은 경우에도 로그인 자체는 성공합니다. 이후 지역 선택 여부를 기준으로 온보딩 화면으로 이동합니다.

## 6. 온보딩 흐름

```text
첫 방문 환영 화면
  ↓
프로필 생성 화면
  ↓
거주 지역 선택 화면
  ↓
profiles에 지역 저장
  ↓
홈 화면 이동
```

### 프로필 생성

프로필 생성 화면에서는 Auth0에서 제공한 기본 닉네임과 이미지를 먼저 표시합니다.

사용자가 저장하면 다음 순서로 처리합니다.

```text
닉네임 확인
  ↓
선택한 이미지가 있으면 Storage 업로드
  ↓
profiles 업데이트
  ↓
기존 프로필 이미지 삭제
  ↓
현재 User 갱신
```

새 이미지 저장이나 프로필 수정이 실패하면 새로 업로드한 이미지를 삭제해 불필요한 Storage 파일이 남지 않도록 처리합니다.

### 거주 지역 선택

거주 지역은 필수 항목입니다.

```text
상위 지역 + 하위 지역 선택
  ↓
profiles.upper_region 저장
profiles.lower_region 저장
  ↓
현재 User 갱신
  ↓
홈 화면 이동
```

상위 지역과 하위 지역 중 하나라도 없으면 지역 선택이 완료되지 않은 것으로 판단합니다.

## 7. Splash 화면 상태 처리

[`splash_screen_root.dart`](../../lib/feature/splash/presentation/screen/splash_screen_root.dart)은 인증 스트림을 직접 관리하지 않습니다.

```text
AuthRepository
  ↓
AuthSessionController
  ↓
ListenableBuilder
  ↓
SplashScreen
```

현재 상태에 따라 다음 화면을 표시합니다.

- `initializing`: 로딩 화면
- `error`: 연결 오류 및 다시 연결하기 화면
- 그 외 상태: 라우터가 Splash를 벗어나도록 처리

기존 `StreamBuilder`는 제거하고, Splash와 GoRouter가 동일한 `AuthSessionController`를 사용하도록 변경했습니다.

## 8. 라우팅 흐름

[`router.dart`](../../lib/core/routing/router.dart)는 `AuthSessionController`를 `refreshListenable`로 사용합니다.

인증 상태가 바뀌면 라우터가 redirect를 다시 계산합니다.

```text
initializing → Splash
error        → Splash
signedOut    → Sign In
signedIn + 지역 미선택 → Onboarding
signedIn + 지역 선택 완료 → Home
```

온보딩 중에는 하위 화면 간 이동 스택을 유지합니다. 지역 선택을 완료해 홈으로 이동하면 온보딩 흐름을 벗어납니다.

## 9. Auth0 토큰 만료 처리

[`auth0_session.dart`](../../lib/core/auth/auth0_session.dart)은 Supabase 요청 전에 Auth0 토큰 상태를 확인합니다.

```text
토큰 유효성 확인
  ↓
토큰 만료 임박 또는 만료
  ↓
Auth0 토큰 갱신
  ↓
갱신된 토큰으로 Supabase 요청
```

이를 통해 만료된 JWT로 인해 Supabase에서 `JWT expired` 오류가 발생하는 문제를 방지합니다.

## 10. 전체 흐름 요약

```text
Auth0 인증
  ↓
AuthDataSource
  ↓
AuthIdentity
  ↓
AuthRepository
  ├─ ProfileRepository에서 프로필 조회
  └─ User 생성 및 세션 상태 관리
  ↓
AuthSessionController
  ├─ Splash 화면 갱신
  └─ GoRouter redirect 갱신
```

인증과 프로필의 실제 접근은 각각의 DataSource와 Repository가 담당합니다. 여러 데이터를 조합하고 앱의 인증 상태를 결정하는 책임은 `AuthRepository`가 담당합니다.
