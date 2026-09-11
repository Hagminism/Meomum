# Flutter feature 구현 rules
flutter(dart) 개발 중, feature 구현(개발) 시에는 아래 규칙을 준수할 것.
1. 하나의 파일에는 하나의 클래스만 둘 것.
2. 아키텍처는 mvvm + mvi 기반 클린 아키텍처를 적용할 것. 해당 아키텍처는 루트의 /docs 디렉터리 내 convention.md 파일을 참고할 것.
3. ~screen.dart 파일 하나에 위젯+로직을 모두 몰아버리지 말 것. 재사용 가능한 위젯은 분리하고, 비즈니스 로직은 viewModel로 분리할 것.
4. 라우팅(context.go/push 등의 이동)은 ~root.dart 파일에서 관리할 것.
5. 액션 처리 중 모든 액션이 라우팅 없이 viewModel의 메서드 호출만을 필요로 한다고 하더라도 widget.viewModel.onAction으로 퉁치지 말고, switch(action) {~} 형태로 모두 분기 처리할 것.
6. ~action.dart/~event.dart 파일은 freezed + sealed class 적용할 것.
7. ~state.dart 파일은 freezed 적용할 것.
8. model 클래스 정의 시 freezed + json_serializable 적용할 것.
9. 클래스 정의 시 생성자 파라미터는 생성자보다 위쪽에 위치하게 할 것. 그 외 getter/setter나 일반 상수 등은 생성바 아래쪽에 두어도 무관함.