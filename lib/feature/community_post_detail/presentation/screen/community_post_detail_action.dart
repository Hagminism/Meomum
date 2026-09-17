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
  const factory CommunityPostDetailAction.replyToComment(String commentId) =
      ReplyToComment;
  const factory CommunityPostDetailAction.toggleCommentLike(String commentId) =
      ToggleCommentLike;
  const factory CommunityPostDetailAction.editComment(String commentId) =
      EditComment;
  const factory CommunityPostDetailAction.changeEditingComment(String content) =
      ChangeEditingComment;
  const factory CommunityPostDetailAction.submitEditingComment() =
      SubmitEditingComment;
  const factory CommunityPostDetailAction.cancelEditingComment() =
      CancelEditingComment;
  const factory CommunityPostDetailAction.deleteComment(String commentId) =
      DeleteComment;
  const factory CommunityPostDetailAction.reportComment(String commentId) =
      ReportComment;
  const factory CommunityPostDetailAction.tapMenu(
    CommunityPostDetailMenuItem item,
  ) = TapMenu;
}
