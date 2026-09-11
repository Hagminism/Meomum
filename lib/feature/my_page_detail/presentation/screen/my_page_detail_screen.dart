import 'package:flutter/material.dart';
import 'package:meomum/core/presentation/component/custom_app_bar.dart';
import 'package:meomum/feature/community/domain/model/community_post.dart';
import 'package:meomum/feature/community/presentation/component/post/community_post_card.dart';
import 'package:meomum/feature/community/presentation/screen/community_action.dart'
    as community;
import 'package:meomum/feature/my_page_detail/presentation/component/my_page_detail_empty_view.dart';
import 'package:meomum/feature/my_page_detail/presentation/component/my_page_detail_profile_header.dart';
import 'package:meomum/feature/my_page_detail/presentation/component/my_page_detail_tab_switch.dart';
import 'package:meomum/feature/my_page_detail/domain/model/enum/my_page_feed_tab.dart';
import 'package:meomum/feature/my_page_detail/presentation/screen/my_page_detail_action.dart';
import 'package:meomum/feature/my_page_detail/presentation/screen/my_page_detail_state.dart';
import 'package:meomum/ui/app_colors.dart';

class MyPageDetailScreen extends StatelessWidget {
  final MyPageDetailState state;
  final void Function(MyPageDetailAction) onAction;
  final void Function(CommunityPost, BuildContext) onShare;
  final Future<void> Function() onRefresh;

  const MyPageDetailScreen({
    super.key,
    required this.state,
    required this.onAction,
    required this.onShare,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom + 16;

    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      appBar: CustomAppBar(
        title: '내 피드',
        toolbarHeight: 44,
        showBackButton: true,
        showMoreButton: true,
        onBackPressed: () {
          onAction(const MyPageDetailAction.tapBack());
        },
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.white,
        onRefresh: onRefresh,
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification notification) {
            if (notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 200) {
              onAction(const MyPageDetailAction.loadMore());
            }
            return false;
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: MyPageDetailProfileHeader(
                    user: state.user,
                    onAction: onAction,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: MyPageDetailTabSwitch(
                  selectedTab: state.selectedTab,
                  onTabPressed: (MyPageFeedTab tab) {
                    onAction(MyPageDetailAction.selectTab(tab));
                  },
                ),
              ),
              if (state.isLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else if (state.isPlaceholderTab)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: MyPageDetailEmptyView(
                    message: '준비 중인 기능입니다.',
                  ),
                )
              else if (state.posts.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: MyPageDetailEmptyView(
                    message: '아직 작성한 글이 없어요.',
                  ),
                )
              else ...[
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      final post = state.posts[index];
                      return CommunityPostCard(
                        post: post,
                        currentImageIndex:
                            state.imagePageByPostId[post.id] ?? 0,
                        onAction: _handlePostAction,
                        onShare: onShare,
                      );
                    },
                    childCount: state.posts.length,
                  ),
                ),
                if (state.isLoadingMore)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                SliverToBoxAdapter(child: SizedBox(height: bottomPadding)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _handlePostAction(community.CommunityAction action) {
    switch (action) {
      case community.TapPost(:final postId):
        onAction(MyPageDetailAction.tapPost(postId));
      case community.ChangeImagePage(:final postId, :final pageIndex):
        onAction(MyPageDetailAction.changeImagePage(postId, pageIndex));
      case community.ToggleLike(:final postId):
        onAction(MyPageDetailAction.toggleLike(postId));
      case community.TapComment(:final postId):
        onAction(MyPageDetailAction.tapComment(postId));
      case community.TapRegionFilter():
      case community.SelectRegion():
      case community.SelectCategory():
      case community.TapWrite():
      case community.LoadMore():
      case community.Refresh():
        break;
    }
  }
}
