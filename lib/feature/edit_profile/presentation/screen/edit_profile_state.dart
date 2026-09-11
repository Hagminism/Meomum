import 'package:freezed_annotation/freezed_annotation.dart';

part 'edit_profile_state.freezed.dart';

@freezed
abstract class EditProfileState with _$EditProfileState {
  const EditProfileState._();

  const factory EditProfileState({
    @Default('') String nickname,
    String? avatarUrl,
    String? selectedImagePath,
    @Default(false) bool isLoading,
  }) = _EditProfileState;

  bool get isValid {
    final trimmedNickname = nickname.trim();
    return trimmedNickname.isNotEmpty && trimmedNickname.length <= 20;
  }
}
