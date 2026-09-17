import 'package:flutter/material.dart';
import 'package:meomum/feature/community/presentation/component/comment/community_comment_list.dart';
import 'package:meomum/feature/home_post_detail/presentation/screen/home_post_detail_action.dart';
import 'package:meomum/feature/home_post_detail/presentation/screen/home_post_detail_state.dart';

class HomePostDetailComments extends StatelessWidget {
  final HomePostDetailState state;
  final void Function(HomePostDetailAction action) onAction;

  const HomePostDetailComments({
    super.key,
    required this.state,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isCommentsLoading && state.comments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 28),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final post = state.post;
    if (post == null) return const SizedBox.shrink();
    return CommunityCommentList(
      comments: state.comments,
      postAuthorId: post.authorId,
      currentUserId: state.currentUserId,
      focusCommentId: state.focusCommentId,
      replyParentId: state.replyParentId,
      editingCommentId: state.editingCommentId,
      editingContent: state.editingCommentContent,
      isEditingSubmitting: state.isEditingCommentSubmitting,
      onReply: (String commentId) => onAction(
        HomePostDetailAction.replyToComment(commentId),
      ),
      onLike: (String commentId) => onAction(
        HomePostDetailAction.toggleCommentLike(commentId),
      ),
      onEdit: (String commentId) => onAction(
        HomePostDetailAction.editComment(commentId),
      ),
      onDelete: (String commentId) => onAction(
        HomePostDetailAction.deleteComment(commentId),
      ),
      onReport: (String commentId) => onAction(
        HomePostDetailAction.reportComment(commentId),
      ),
      onEditChanged: (String content) => onAction(
        HomePostDetailAction.changeEditingComment(content),
      ),
      onEditSubmit: () => onAction(
        const HomePostDetailAction.submitEditingComment(),
      ),
      onEditCancel: () => onAction(
        const HomePostDetailAction.cancelEditingComment(),
      ),
    );
  }
}
