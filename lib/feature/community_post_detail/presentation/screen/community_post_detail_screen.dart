import 'package:flutter/material.dart';
import 'package:meomum/core/presentation/component/custom_app_bar.dart';
import 'package:meomum/feature/community_post_detail/presentation/component/community_post_detail_comment_input.dart';
import 'package:meomum/feature/community_post_detail/presentation/component/community_post_detail_comments.dart';
import 'package:meomum/feature/community_post_detail/presentation/component/community_post_detail_footer.dart';
import 'package:meomum/feature/community_post_detail/presentation/component/community_post_detail_images.dart';
import 'package:meomum/feature/community/presentation/component/post/community_post_header.dart';
import 'package:meomum/feature/community_post_detail/presentation/screen/community_post_detail_action.dart';
import 'package:meomum/feature/community_post_detail/presentation/screen/community_post_detail_state.dart';
import 'package:meomum/ui/app_colors.dart';

class CommunityPostDetailScreen extends StatelessWidget {
  final CommunityPostDetailState state;
  final void Function(CommunityPostDetailAction action) onAction;

  const CommunityPostDetailScreen({
    super.key,
    required this.state,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final post = state.post;

    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      appBar: CustomAppBar(
        title: post == null ? '커뮤니티' : post.category.label,
        titleColor: AppColors.feedContentText,
        toolbarHeight: 44,
        showBackButton: true,
        onBackPressed: () {
          onAction(const CommunityPostDetailAction.tapBack());
        },
        showMoreButton: post != null,
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
                      SliverToBoxAdapter(child: const SizedBox(height: 12)),
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
                          onShare: () {
                            onAction(
                              const CommunityPostDetailAction.tapShare(),
                            );
                          },
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: ColoredBox(
                          color: AppColors.inputBackground,
                          child: SizedBox(height: 2),
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: CommunityPostDetailComments(),
                      ),
                    ],
                  ),
          ),
          if (post != null && !state.isLoading)
            CommunityPostDetailCommentInput(state: state, onAction: onAction),
        ],
      ),
    );
  }
}
