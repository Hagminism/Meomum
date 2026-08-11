import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_page_action.freezed.dart';

@freezed
sealed class MyPageAction with _$MyPageAction {
  const factory MyPageAction.tapMyFeed() = TapMyFeed;
  const factory MyPageAction.tapProfile() = TapProfile;
  const factory MyPageAction.tapCurrentStayMenu() = TapCurrentStayMenu;
  const factory MyPageAction.tapCategory(String id) = TapCategory;
  const factory MyPageAction.tapStayHistory(String id) = TapStayHistory;
  const factory MyPageAction.tapStayHistoryMenu(String id) = TapStayHistoryMenu;
  const factory MyPageAction.tapLogout() = TapLogout;
}
