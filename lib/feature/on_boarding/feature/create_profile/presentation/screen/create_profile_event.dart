import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_profile_event.freezed.dart';

@freezed
sealed class CreateProfileEvent with _$CreateProfileEvent {
  const factory CreateProfileEvent.showError(String message) = ShowError;
  const factory CreateProfileEvent.profileSaved() = ProfileSaved;
}
