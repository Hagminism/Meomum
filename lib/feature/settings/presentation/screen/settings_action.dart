import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_action.freezed.dart';

@freezed
sealed class SettingsAction with _$SettingsAction {
  const factory SettingsAction.tapBack() = TapBack;
  const factory SettingsAction.tapNotices() = TapNotices;
  const factory SettingsAction.tapPrivacyPolicy() = TapPrivacyPolicy;
  const factory SettingsAction.tapLogout() = TapLogout;
  const factory SettingsAction.tapDeleteAccount() = TapDeleteAccount;
}
