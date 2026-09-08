import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_profile_state.freezed.dart';

@freezed
abstract class CreateProfileState with _$CreateProfileState {
  const CreateProfileState._();

  const factory CreateProfileState({
    @Default('') String nickname,
    String? avatarUrl,
    String? selectedImagePath,
    @Default(false) bool isLoading,
  }) = _CreateProfileState;

  bool get isValid {
    final trimmedNickname = nickname.trim();
    return trimmedNickname.isNotEmpty && trimmedNickname.length <= 20;
  }
}
