import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meomum/feature/community/domain/model/enum/community_category.dart';
import 'package:meomum/feature/community/presentation/component/category/community_category_filter_bar.dart';
import 'package:meomum/feature/community/presentation/component/post/community_post_card.dart';
import 'package:meomum/feature/community/presentation/component/region/community_region_header.dart';
import 'package:meomum/feature/community/presentation/component/screen/community_empty_view.dart';
import 'package:meomum/feature/community/presentation/component/screen/community_write_button.dart';
import 'package:meomum/feature/community/presentation/screen/community_action.dart';
import 'package:meomum/feature/community/presentation/screen/community_state.dart';
import 'package:meomum/ui/app_colors.dart';

class CommunityScreen extends StatelessWidget {
  final CommunityState state;
  final void Function(CommunityAction action) onAction;

  const CommunityScreen({
    super.key,
    required this.state,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final bottomSafeArea = MediaQuery.paddingOf(context).bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.homeBackground,
        body: Stack(
          children: [
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  CommunityRegionHeader(
                    region: state.selectedRegion,
                    onPressed: () {
                      onAction(const CommunityAction.tapRegionFilter());
                    },
                  ),
                  CommunityCategoryFilterBar(
                    selectedCategory: state.selectedCategory,
                    onCategoryPressed: (CommunityCategory category) {
                      onAction(CommunityAction.selectCategory(category));
                    },
                  ),
                  Expanded(
                    child: state.visiblePosts.isEmpty
                        ? CommunityEmptyView(
                            regionLabel:
                                '${state.selectedRegion.upperRegion} '
                                '${state.selectedRegion.lowerRegion}',
                          )
                        : ListView.builder(
                            padding: EdgeInsets.only(
                              bottom: bottomSafeArea + 164,
                            ),
                            itemCount: state.visiblePosts.length,
                            itemBuilder: (BuildContext context, int index) {
                              final post = state.visiblePosts[index];

                              return CommunityPostCard(
                                post: post,
                                currentImageIndex:
                                    state.imagePageByPostId[post.id] ?? 0,
                                onAction: onAction,
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 20,
              bottom: bottomSafeArea + 20,
              child: CommunityWriteButton(
                onPressed: () {
                  onAction(const CommunityAction.tapWrite());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
