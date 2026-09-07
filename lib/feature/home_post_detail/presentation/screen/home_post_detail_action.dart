import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_post_detail_action.freezed.dart';

enum HomePostDetailMenuItem { edit, delete, report }

@freezed
sealed class HomePostDetailAction with _$HomePostDetailAction {
  const factory HomePostDetailAction.tapBack() = TapBack;
  const factory HomePostDetailAction.toggleLike() = ToggleLike;
  const factory HomePostDetailAction.changeComment(String content) =
      ChangeComment;
  const factory HomePostDetailAction.pickImage() = PickImage;
  const factory HomePostDetailAction.submitComment() = SubmitComment;
  const factory HomePostDetailAction.tapShare() = TapShare;
  const factory HomePostDetailAction.tapMenu(HomePostDetailMenuItem item) =
      TapMenu;
}
