import 'package:freezed_annotation/freezed_annotation.dart';

part 'edit_profile_event.freezed.dart';

@freezed
sealed class EditProfileEvent with _$EditProfileEvent {
  const factory EditProfileEvent.showError(String message) = ShowError;
  const factory EditProfileEvent.profileSaved() = ProfileSaved;
}
