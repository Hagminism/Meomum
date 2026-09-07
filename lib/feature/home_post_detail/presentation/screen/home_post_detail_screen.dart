import 'package:flutter/material.dart';
import 'package:meomum/core/presentation/component/custom_app_bar.dart';
import 'package:meomum/feature/home_post_detail/presentation/component/home_post_detail_comment_input.dart';
import 'package:meomum/feature/home_post_detail/presentation/component/home_post_detail_comments.dart';
import 'package:meomum/feature/home_post_detail/presentation/component/home_post_detail_footer.dart';
import 'package:meomum/feature/home_post_detail/presentation/component/home_post_detail_images.dart';
import 'package:meomum/feature/community/presentation/component/post/community_post_header.dart';
import 'package:meomum/feature/home_post_detail/presentation/screen/home_post_detail_action.dart';
import 'package:meomum/feature/home_post_detail/presentation/screen/home_post_detail_state.dart';
import 'package:meomum/ui/app_colors.dart';

class HomePostDetailScreen extends StatelessWidget {
  final HomePostDetailState state;
  final void Function(HomePostDetailAction action) onAction;

  const HomePostDetailScreen({
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
          onAction(const HomePostDetailAction.tapBack());
        },
        showMoreButton: post != null,
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
                      SliverToBoxAdapter(child: const SizedBox(height: 12)),
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
                          onShare: () {
                            onAction(const HomePostDetailAction.tapShare());
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
                        child: HomePostDetailComments(),
                      ),
                    ],
                  ),
          ),
          if (post != null && !state.isLoading)
            HomePostDetailCommentInput(state: state, onAction: onAction),
        ],
      ),
    );
  }
}
