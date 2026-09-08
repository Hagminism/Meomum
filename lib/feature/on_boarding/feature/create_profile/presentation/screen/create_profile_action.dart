import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_profile_action.freezed.dart';

@freezed
sealed class CreateProfileAction with _$CreateProfileAction {
  const factory CreateProfileAction.tapAvatar() = TapAvatar;
  const factory CreateProfileAction.changeNickname(String nickname) =
      ChangeNickname;
  const factory CreateProfileAction.tapBack() = TapBack;
  const factory CreateProfileAction.tapSubmit() = TapSubmit;
}
