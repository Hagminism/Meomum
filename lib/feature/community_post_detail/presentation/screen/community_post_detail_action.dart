import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_post_detail_action.freezed.dart';

enum CommunityPostDetailMenuItem { edit, delete, report }

@freezed
sealed class CommunityPostDetailAction with _$CommunityPostDetailAction {
  const factory CommunityPostDetailAction.tapBack() = TapBack;
  const factory CommunityPostDetailAction.toggleLike() = ToggleLike;
  const factory CommunityPostDetailAction.changeComment(String content) =
      ChangeComment;
  const factory CommunityPostDetailAction.pickImage() = PickImage;
  const factory CommunityPostDetailAction.submitComment() = SubmitComment;
  const factory CommunityPostDetailAction.tapMenu(
    CommunityPostDetailMenuItem item,
  ) = TapMenu;
}
