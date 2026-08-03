import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_page_action.freezed.dart';

@freezed
sealed class MyPageAction with _$MyPageAction {
  const factory MyPageAction.tapLogout() = TapLogout;
}
