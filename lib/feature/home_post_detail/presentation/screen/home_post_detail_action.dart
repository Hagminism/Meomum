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
  const factory HomePostDetailAction.replyToComment(String commentId) =
      ReplyToComment;
  const factory HomePostDetailAction.toggleCommentLike(String commentId) =
      ToggleCommentLike;
  const factory HomePostDetailAction.editComment(String commentId) =
      EditComment;
  const factory HomePostDetailAction.changeEditingComment(String content) =
      ChangeEditingComment;
  const factory HomePostDetailAction.submitEditingComment() =
      SubmitEditingComment;
  const factory HomePostDetailAction.cancelEditingComment() =
      CancelEditingComment;
  const factory HomePostDetailAction.deleteComment(String commentId) =
      DeleteComment;
  const factory HomePostDetailAction.reportComment(String commentId) =
      ReportComment;
  const factory HomePostDetailAction.tapMenu(HomePostDetailMenuItem item) =
      TapMenu;
}
