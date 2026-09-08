import 'package:freezed_annotation/freezed_annotation.dart';

part 'on_boarding_action.freezed.dart';

@freezed
sealed class OnBoardingAction with _$OnBoardingAction {
  const factory OnBoardingAction.tapCreateProfile() = TapCreateProfile;
}
