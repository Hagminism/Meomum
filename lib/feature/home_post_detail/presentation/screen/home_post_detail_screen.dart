import 'package:flutter/material.dart';
import 'package:meomum/core/presentation/component/custom_app_bar.dart';
import 'package:meomum/feature/home_post_detail/presentation/component/home_post_detail_comment_input.dart';
import 'package:meomum/feature/home_post_detail/presentation/component/home_post_detail_footer.dart';
import 'package:meomum/feature/home_post_detail/presentation/component/home_post_detail_images.dart';
import 'package:meomum/feature/community/presentation/component/post/community_post_header.dart';
import 'package:meomum/feature/community/presentation/component/comment/community_comment_list.dart';
import 'package:meomum/feature/home_post_detail/presentation/screen/home_post_detail_action.dart';
import 'package:meomum/feature/home_post_detail/presentation/screen/home_post_detail_state.dart';
import 'package:meomum/ui/app_colors.dart';

class HomePostDetailScreen extends StatelessWidget {
  final HomePostDetailState state;
  final void Function(HomePostDetailAction action) onAction;
  final void Function(BuildContext) onShare;

  const HomePostDetailScreen({
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
                  onAction(const HomePostDetailAction.tapBack());
                }
              },
              showMoreButton: post != null && !state.isDeleting,
              moreItemBuilder: (BuildContext context) {
                return [
                  if (state.isOwner)
                    const PopupMenuItem<Object>(
                      value: HomePostDetailMenuItem.edit,
                      child: Text('글 수정'),
                    ),
                  if (state.isOwner)
                    const PopupMenuItem<Object>(
                      value: HomePostDetailMenuItem.delete,
                      child: Text('글 삭제'),
                    ),
                  const PopupMenuItem<Object>(
                    value: HomePostDetailMenuItem.report,
                    child: Text('신고하기'),
                  ),
                ];
              },
              onMoreSelected: (Object value) {
                onAction(
                  HomePostDetailAction.tapMenu(value as HomePostDetailMenuItem),
                );
              },
            ),
            body: Column(
              children: [
                if (state.isDeleting)
                  const LinearProgressIndicator(
                    minHeight: 2,
                    color: AppColors.primary,
                  ),
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
                                    color: AppColors.communityText,
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
                                child: HomePostDetailImages(post: post),
                              ),
                            SliverToBoxAdapter(
                              child: HomePostDetailFooter(
                                post: post,
                                onLike: () {
                                  onAction(
                                    const HomePostDetailAction.toggleLike(),
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
                                      isEditingSubmitting:
                                          state.isEditingCommentSubmitting,
                                      onReply: (String commentId) {
                                        onAction(
                                          HomePostDetailAction.replyToComment(
                                            commentId,
                                          ),
                                        );
                                      },
                                      onLike: (String commentId) {
                                        onAction(
                                          HomePostDetailAction.toggleCommentLike(
                                            commentId,
                                          ),
                                        );
                                      },
                                      onEdit: (String commentId) {
                                        onAction(
                                          HomePostDetailAction.editComment(
                                            commentId,
                                          ),
                                        );
                                      },
                                      onDelete: (String commentId) {
                                        onAction(
                                          HomePostDetailAction.deleteComment(
                                            commentId,
                                          ),
                                        );
                                      },
                                      onReport: (String commentId) {
                                        onAction(
                                          HomePostDetailAction.reportComment(
                                            commentId,
                                          ),
                                        );
                                      },
                                      onEditChanged: (String content) {
                                        onAction(
                                          HomePostDetailAction.changeEditingComment(
                                            content,
                                          ),
                                        );
                                      },
                                      onEditSubmit: () {
                                        onAction(
                                          const HomePostDetailAction.submitEditingComment(),
                                        );
                                      },
                                      onEditCancel: () {
                                        onAction(
                                          const HomePostDetailAction.cancelEditingComment(),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                ),
                if (post != null && !state.isLoading && !state.isDeleting)
                  HomePostDetailCommentInput(state: state, onAction: onAction),
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
