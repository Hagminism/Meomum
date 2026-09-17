import 'package:flutter/material.dart';
import 'package:meomum/core/presentation/component/custom_app_bar.dart';
import 'package:meomum/feature/community_post_detail/presentation/component/community_post_detail_comment_input.dart';
import 'package:meomum/feature/community_post_detail/presentation/component/community_post_detail_footer.dart';
import 'package:meomum/feature/community_post_detail/presentation/component/community_post_detail_images.dart';
import 'package:meomum/feature/community/presentation/component/post/community_post_header.dart';
import 'package:meomum/feature/community/presentation/component/comment/community_comment_list.dart';
import 'package:meomum/feature/community_post_detail/presentation/screen/community_post_detail_action.dart';
import 'package:meomum/feature/community_post_detail/presentation/screen/community_post_detail_state.dart';
import 'package:meomum/ui/app_colors.dart';

class CommunityPostDetailScreen extends StatelessWidget {
  final CommunityPostDetailState state;
  final void Function(CommunityPostDetailAction action) onAction;
  final void Function(BuildContext) onShare;

  const CommunityPostDetailScreen({
    super.key,
    required this.state,
    required this.onAction,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final post = state.post;

    return PopScope(
      canPop: state.isDeleting ? false : true,
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: AppColors.homeBackground,
            appBar: CustomAppBar(
              title: post == null ? '커뮤니티' : post.category.label,
              titleColor: AppColors.feedContentText,
              toolbarHeight: 44,
              showBackButton: true,
              onBackPressed: () {
                if (!state.isDeleting) {
                  onAction(const CommunityPostDetailAction.tapBack());
                }
              },
              showMoreButton: post != null && !state.isDeleting,
              moreItemBuilder: (BuildContext context) {
                return [
                  if (state.isOwner)
                    const PopupMenuItem<Object>(
                      value: CommunityPostDetailMenuItem.edit,
                      child: Text('글 수정'),
                    ),
                  if (state.isOwner)
                    const PopupMenuItem<Object>(
                      value: CommunityPostDetailMenuItem.delete,
                      child: Text('글 삭제'),
                    ),
                  const PopupMenuItem<Object>(
                    value: CommunityPostDetailMenuItem.report,
                    child: Text('신고하기'),
                  ),
                ];
              },
              onMoreSelected: (Object value) {
                onAction(
                  CommunityPostDetailAction.tapMenu(
                    value as CommunityPostDetailMenuItem,
                  ),
                );
              },
            ),
            body: Column(
              children: [
                Expanded(
                  child: state.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        )
                      : post == null
                      ? const Center(child: Text('게시글을 불러오지 못했습니다.'))
                      : CustomScrollView(
                          slivers: [
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                child: Text(
                                  post.title,
                                  style: const TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: CommunityPostHeader(post: post),
                            ),
                            SliverToBoxAdapter(
                              child: const SizedBox(height: 12),
                            ),
                            if (post.imageUrls.isNotEmpty)
                              SliverToBoxAdapter(
                                child: CommunityPostDetailImages(post: post),
                              ),
                            SliverToBoxAdapter(
                              child: CommunityPostDetailFooter(
                                post: post,
                                onLike: () {
                                  onAction(
                                    const CommunityPostDetailAction.toggleLike(),
                                  );
                                },
                                onShare: onShare,
                              ),
                            ),
                            const SliverToBoxAdapter(
                              child: ColoredBox(
                                color: AppColors.inputBackground,
                                child: SizedBox(height: 2),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: state.isCommentsLoading
                                  ? const Padding(
                                      padding: EdgeInsets.all(24),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    )
                                  : CommunityCommentList(
                                      comments: state.comments,
                                      postAuthorId: post.authorId,
                                      currentUserId: state.currentUserId,
                                      focusCommentId: state.focusCommentId,
                                      replyParentId: state.replyParentId,
                                      editingCommentId: state.editingCommentId,
                                      editingContent:
                                          state.editingCommentContent,
                                      onReply: (String commentId) {
                                        onAction(
                                          CommunityPostDetailAction.replyToComment(
                                            commentId,
                                          ),
                                        );
                                      },
                                      onLike: (String commentId) {
                                        onAction(
                                          CommunityPostDetailAction.toggleCommentLike(
                                            commentId,
                                          ),
                                        );
                                      },
                                      onEdit: (String commentId) {
                                        onAction(
                                          CommunityPostDetailAction.editComment(
                                            commentId,
                                          ),
                                        );
                                      },
                                      onDelete: (String commentId) {
                                        onAction(
                                          CommunityPostDetailAction.deleteComment(
                                            commentId,
                                          ),
                                        );
                                      },
                                      onReport: (String commentId) {
                                        onAction(
                                          CommunityPostDetailAction.reportComment(
                                            commentId,
                                          ),
                                        );
                                      },
                                      onEditChanged: (String content) {
                                        onAction(
                                          CommunityPostDetailAction.changeEditingComment(
                                            content,
                                          ),
                                        );
                                      },
                                      onEditSubmit: () {
                                        onAction(
                                          const CommunityPostDetailAction.submitEditingComment(),
                                        );
                                      },
                                      onEditCancel: () {
                                        onAction(
                                          const CommunityPostDetailAction.cancelEditingComment(),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                ),
                if (post != null && !state.isLoading && !state.isDeleting)
                  CommunityPostDetailCommentInput(
                    state: state,
                    onAction: onAction,
                  ),
              ],
            ),
          ),
          if (state.isDeleting)
            ColoredBox(
              color: AppColors.black.withValues(alpha: 0.3),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }
}
