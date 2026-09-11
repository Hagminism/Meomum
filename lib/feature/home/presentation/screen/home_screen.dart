import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:meomum/core/presentation/component/category_item.dart';
import 'package:meomum/feature/home/presentation/component/home_banner_section.dart';
import 'package:meomum/feature/home/presentation/component/home_feed_card.dart';
import 'package:meomum/feature/home/presentation/screen/home_action.dart';
import 'package:meomum/feature/home/presentation/screen/home_state.dart';
import 'package:meomum/ui/app_colors.dart';

class HomeScreen extends StatelessWidget {
  final HomeState state;
  final void Function(HomeAction) onAction;
  final Future<void> Function() onRefresh;

  const HomeScreen({
    super.key,
    required this.state,
    required this.onAction,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom + 88;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.homeBackground,
        body: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.white,
          onRefresh: onRefresh,
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              if (notification.depth == 0 &&
                  notification.metrics.axis == Axis.vertical &&
                  notification is ScrollUpdateNotification &&
                  notification.metrics.extentAfter < 200) {
                onAction(const HomeAction.loadMore());
              }
              return false;
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: 470,
                  stretch: true,
                  pinned: false,
                  floating: false,
                  toolbarHeight: 0,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  backgroundColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    stretchModes: const [StretchMode.zoomBackground],
                    collapseMode: CollapseMode.parallax,
                    background: HomeBannerSection(
                      banners: state.banners,
                      currentIndex: state.currentBannerIndex,
                      onAction: onAction,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: SizedBox(
                      height: 84,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: state.categories.length,
                        separatorBuilder: (BuildContext context, int index) {
                          return const SizedBox(width: 20);
                        },
                        itemBuilder: (BuildContext context, int index) {
                          return CategoryItem(
                            category: state.categories[index],
                            onTap: (String id) {
                              onAction(HomeAction.tapCategory(id));
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 30, 20, 12),
                    child: Text(
                      '지금 머뭄에서는',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.black,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
                if (state.isLoading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  )
                else if (state.feedItems.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text('사진이 있는 게시글이 없습니다.'),
                    ),
                  )
                else ...[
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding),
                    sliver: SliverMasonryGrid.extent(
                      maxCrossAxisExtent: 193,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      itemBuilder: (context, index) {
                        return HomeFeedCard(
                          item: state.feedItems[index],
                          onAction: onAction,
                        );
                      },
                      childCount: state.feedItems.length,
                    ),
                  ),
                  if (state.isLoadingMore)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(top: 16, bottom: 24),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
