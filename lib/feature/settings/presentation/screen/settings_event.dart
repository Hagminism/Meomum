import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_event.freezed.dart';

@freezed
sealed class SettingsEvent with _$SettingsEvent {
  const factory SettingsEvent.showError(String message) = ShowError;
  const factory SettingsEvent.showMessage(String message) = ShowMessage;
}
