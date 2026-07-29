## 1. 코딩 컨벤션 (Coding Conventions)
- **주석 (Comments):** 복잡한 로직인 경우만, UI 길어지면 적극적으로 달기
- **폴더/파일 네이밍:** 폴더는 줄임말, 파일은 풀네임
- **브랜치 네이밍:** develop, feature/(AI 추천)

---

## 2. 커밋 메시지 컨벤션 (Commit Message Conventions)
- **타입 분류 (Types):**
    - `feat`: 새로운 기능 추가
    - `fix`: 버그 수정
    - `docs`: 문서 변경
    - `refactor`: 코드 리팩토링 (기능 변경 없이 코드 개선)
    - `test`: 테스트 코드 추가 및 수정
    - `chore`: 빌드 시스템, 패키지 매니저 설정 등 (프로덕션 코드와 관련 없음)

---

## 3. 폴더/파일 구조 컨벤션 (Folder/File Structure Conventions)

### 1. 최상위 디렉토리 구조
프로젝트의 최상위 lib 디렉토리 아래에는 다음과 같은 주요 디렉토리를 가집니다.
```
lib
├── core        # 모든 Feature에서 공유되는 핵심 로직 및 유틸리티
├── di          # 의존성 주입 (Dependency Injection) 설정
├── feature     # 애플리케이션의 주요 기능 (Feature)별 모듈
├── ui          # 공통 UI 요소 (디자인 시스템, 테마, 색상 등)
├── main.dart   # 애플리케이션의 진입점
```

### 2. core 디렉토리 컨벤션
core 디렉토리는 애플리케이션 전체에서 재사용되는 범용적인 구성 요소와 비즈니스 로직을 포함합니다. 클린 아키텍처의 도메인(Domain), 데이터(Data), 프레젠테이션(Presentation) 레이어에 해당하는 추상적인 정의와 공통 유틸리티를 담습니다.
```
lib/core
├── data            # 데이터 레이어: 외부 데이터 소스와 상호작용
│   ├── data_source # 데이터 획득/저장 방식(API, DB 등) 정의 및 구현
│   │   └── [domain_name] # 도메인별 데이터 소스 (예: recipe)
│   │       ├── [domain]_data_source.dart         # 추상 인터페이스 (데이터 획득/저장 계약)
│   │       └── [domain]_data_source_impl.dart    # 실제 구현 (API 호출, DB 쿼리 등)
│   ├── dto         # Data Transfer Object: 네트워크/DB에서 받은 원시 데이터 구조
│   │   └── [domain_name]
│   │       ├── [entity]_dto.dart                  # 단일 엔티티 DTO (예: recipe_dto.dart)
│   │       └── [entity]_list_dto.dart             # 리스트 형태의 엔티티 DTO (예: recipe_list_dto.dart)
│   ├── mapper      # DTO를 도메인 모델로, 도메인 모델을 DTO로 변환하는 로직
│   │   └── [domain_name]
│   │       └── [entity]_mapper.dart
│   └── repository  # 데이터 레이어의 저장소 구현 (도메인 레이어의 계약 이행)
│       └── [domain_name]
│           └── [domain]_repository_impl.dart
├── domain          # 도메인 레이어: 순수 비즈니스 로직 정의 (플랫폼/프레임워크 독립적)
│   ├── model       # 핵심 비즈니스 엔티티 (pure Dart objects)
│   │   └── [domain_name]
│   │       ├── [entity].dart                      # 엔티티 모델 (freezed 사용 시 .freezed.dart도 함께)
│   │       └── [entity].freezed.dart
│   ├── repository  # 추상 저장소 인터페이스 (데이터 획득/저장 계약 정의)
│   │   └── [domain_name]
│   │       └── [domain]_repository.dart
│   └── use_case    # 비즈니스 로직의 단위 기능 (repository를 사용하여 특정 작업을 수행)
│       └── [use_case_name]_use_case.dart
├── presentation    # 공통 UI 컴포넌트 (Feature에 종속되지 않는)
│   ├── component   # 재사용 가능한 작은 UI 위젯 그룹 (Atomic Design 원칙에 따라)
│   │   ├── button
│   │   │   └── [button_name]_button.dart
│   │   ├── constants  # 컴포넌트 관련 상수 (예: 패딩, 마진, 폰트 사이즈 등)
│   │   │   └── component_constant.dart
│   │   ├── dialog
│   │   │   └── [dialog_name]_dialog.dart
│   │   ├── input
│   │   │   └── [input_name]_field.dart
│   │   ├── list_item
│   │   │   └── [item_name]_item.dart
│   │   ├── other   # 위에 분류되지 않는 기타 컴포넌트
│   │   └── tab
│   │       └── [tab_type]_tabs.dart
├── routing         # 앱 내비게이션 및 라우팅 관련 설정
│   ├── query_parameters.dart
│   ├── router.dart
│   └── routes.dart
└── utils           # 범용 유틸리티 함수, 헬퍼 클래스, 확장 함수
    ├── extension
    │   └── [type]_extension.dart
    ├── network_error.dart      # 네트워크 관련 공통 에러 정의
    ├── network_validator_mixin.dart
    ├── response.dart           # API 응답 모델 (Generic)
    ├── result.dart             # 비동기 작업 결과 처리 (Success/Failure)
    └── result.freezed.dart
```
core 디렉토리 주요 컨벤션:
레이어 분리: data, domain, presentation으로 명확히 레이어를 분리합니다.

도메인별 하위 디렉토리: 각 레이어 내에서 recipe와 같이 도메인(또는 비즈니스 엔티티) 별로 다시 디렉토리를 나눕니다. 이는 관련 파일들을 함께 묶어 찾기 쉽게 합니다.

인터페이스-구현 분리: data_source 및 repository는 항상 추상 인터페이스(.dart 파일)와 구현(.impl.dart 파일)을 분리합니다. 이는 테스트 용이성과 유연성을 높입니다.

DTO/Model/Mapper: 데이터 전송 객체(DTO)와 도메인 모델(Model)을 분리하고, 이 둘 간의 변환을 담당하는 매퍼(Mapper)를 두어 데이터 계층과 도메인 계층 간의 의존성을 줄입니다.

use_case: 도메인 레이어의 핵심입니다. 특정 비즈니스 시나리오를 수행하는 단일 책임 원칙을 따르는 클래스들입니다.

core/presentation/component: 앱 전반에 걸쳐 사용될 수 있는 범용적인 UI 컴포넌트들을 모아둡니다. 특정 feature에 종속되지 않아야 합니다.

### 3. di 디렉토리 컨벤션
의존성 주입을 위한 설정 파일들을 모아둡니다. get_it이나 injectable과 같은 DI 패키지를 사용할 때 활용됩니다.
```
lib/di
└── di.dart # 모든 의존성 주입 설정을 한 곳에서 관리 (혹은 feature별 모듈화)
```

### 4. feature 디렉토리 컨벤션
feature 디렉토리는 애플리케이션의 각 **독립적인 기능 단위(Feature)**를 모듈화합니다. 각 Feature는 자체적인 상태 관리, UI, 그리고 해당 Feature에 특화된 비즈니스 로직을 가집니다.
```
lib/feature
├── [feature_name_1] # 예: authentication, home, ingredient 등
│   ├── data        # 해당 Feature에 특화된 데이터 레이어 (선택 사항)
│   │   └── repository
│   │       └── mocks # Mock 구현 (테스트, 스토리북 등)
│   │           └── mock_[feature]_repository_impl.dart
│   ├── domain      # 해당 Feature에 특화된 도메인 레이어 (선택 사항)
│   │   ├── model
│   │   │   └── [feature_model].dart
│   │   ├── repository # 해당 Feature에 특화된 저장소 인터페이스 (선택 사항)
│   │   │   └── [feature]_repository.dart
│   │   └── use_case
│   │       └── [feature_use_case].dart
│   └── presentation # 해당 Feature의 UI 및 상태 관리
│       ├── component # 해당 Feature 내에서만 사용되는 UI 컴포넌트
│       │   └── [feature_component].dart
│       ├── [feature]_action.dart       # 특정 ViewModel에서 발생시키는 side-effect성 액션 (옵션)
│       ├── [feature]_action.freezed.dart
│       ├── [feature]_event.dart        # BLoC에 전달될 이벤트 정의 (BLoC 사용 시)
│       ├── [feature]_event.freezed.dart
│       ├── [feature]_screen_root.dart  # 해당 Feature의 최상위 위젯 (BlocProvider 설정 등)
│       ├── [feature]_screen.dart       # 해당 Feature의 메인 UI 화면
│       ├── [feature]_state.dart        # ViewModel의 상태 정의
│       ├── [feature]_state.freezed.dart
│       └── [feature]_view_model.dart   # ViewModel 구현 파일
├── main_navigation # 메인 내비게이션 (하단 탭 바, 드로어 등)
│   └── presentation
│       └── main_navigation_screen.dart
```
feature 디렉토리 주요 컨벤션:
독립성: 각 Feature는 다른 Feature에 직접적으로 의존하지 않아야 합니다. (공통 core는 예외)

_screen_root.dart: 해당 스크린에 필요한 의존성 주입 및 ViewModel 초기화를 담당하는 Root 위젯을 분리하여 _screen.dart는 순수하게 UI만 담당하도록 합니다.

component: Feature 내에서만 사용되는 특정 컴포넌트는 해당 Feature의 presentation/component 디렉토리에 둡니다.

### 5. ui 디렉토리 컨벤션
앱의 전반적인 디자인 시스템을 정의하는 곳입니다.
```
lib/ui
├── app_colors.dart   # 앱의 모든 색상 팔레트 정의
└── text_styles.dart  # 앱의 모든 텍스트 스타일 정의 (폰트, 크기, 볼드 등)
```

---

## 6. Merge 기준
- Gemini 리뷰 후 지적 사항 없을 경우