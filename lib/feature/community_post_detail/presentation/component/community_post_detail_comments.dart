import 'package:flutter/material.dart';
import 'package:meomum/feature/community/presentation/component/comment/community_comment_list.dart';
import 'package:meomum/feature/community_post_detail/presentation/screen/community_post_detail_action.dart';
import 'package:meomum/feature/community_post_detail/presentation/screen/community_post_detail_state.dart';

class CommunityPostDetailComments extends StatelessWidget {
  final CommunityPostDetailState state;
  final void Function(CommunityPostDetailAction action) onAction;

  const CommunityPostDetailComments({
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
        CommunityPostDetailAction.replyToComment(commentId),
      ),
      onLike: (String commentId) => onAction(
        CommunityPostDetailAction.toggleCommentLike(commentId),
      ),
      onEdit: (String commentId) => onAction(
        CommunityPostDetailAction.editComment(commentId),
      ),
      onDelete: (String commentId) => onAction(
        CommunityPostDetailAction.deleteComment(commentId),
      ),
      onReport: (String commentId) => onAction(
        CommunityPostDetailAction.reportComment(commentId),
      ),
      onEditChanged: (String content) => onAction(
        CommunityPostDetailAction.changeEditingComment(content),
      ),
      onEditSubmit: () => onAction(
        const CommunityPostDetailAction.submitEditingComment(),
      ),
      onEditCancel: () => onAction(
        const CommunityPostDetailAction.cancelEditingComment(),
      ),
    );
  }
}
