import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_notice_action.freezed.dart';

@freezed
sealed class SettingsNoticeAction with _$SettingsNoticeAction {
  const factory SettingsNoticeAction.tapBack() = TapBack;
  const factory SettingsNoticeAction.toggleNotice(String id) = ToggleNotice;
}
