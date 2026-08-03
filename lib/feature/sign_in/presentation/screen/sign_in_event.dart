import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_in_event.freezed.dart';

@freezed
sealed class SignInEvent with _$SignInEvent {
  const factory SignInEvent.showError(String message) = ShowError;
  const factory SignInEvent.showMessage(String message) = ShowMessage;
}
