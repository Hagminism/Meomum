import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_in_action.freezed.dart';

@freezed
sealed class SignInAction with _$SignInAction {
  const factory SignInAction.tapGoogle() = TapGoogle;
  const factory SignInAction.tapApple() = TapApple;
  const factory SignInAction.tapKakao() = TapKakao;
  const factory SignInAction.tapNaver() = TapNaver;
}
