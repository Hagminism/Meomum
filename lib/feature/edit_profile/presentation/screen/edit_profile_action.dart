import 'package:freezed_annotation/freezed_annotation.dart';

part 'edit_profile_action.freezed.dart';

@freezed
sealed class EditProfileAction with _$EditProfileAction {
  const factory EditProfileAction.tapAvatar() = TapAvatar;
  const factory EditProfileAction.changeNickname(String nickname) =
      ChangeNickname;
  const factory EditProfileAction.tapBack() = TapBack;
  const factory EditProfileAction.tapSubmit() = TapSubmit;
}
