import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meomum/core/presentation/component/custom_app_bar.dart';
import 'package:meomum/feature/my_page/presentation/component/my_page_profile_header.dart';
import 'package:meomum/feature/my_page/presentation/component/my_page_promotion_carousel.dart';
import 'package:meomum/feature/my_page/presentation/component/my_page_service_section.dart';
import 'package:meomum/feature/my_page/presentation/screen/my_page_action.dart';
import 'package:meomum/feature/my_page/presentation/screen/my_page_state.dart';
import 'package:meomum/ui/app_colors.dart';

class MyPageScreen extends StatelessWidget {
  final MyPageState state;
  final void Function(MyPageAction) onAction;
  final Future<void> Function() onRefresh;

  const MyPageScreen({
    super.key,
    required this.state,
    required this.onAction,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom + 88;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        appBar: CustomAppBar(
          toolbarHeight: 44,
          onSettingsTap: () {
            onAction(const MyPageAction.tapSettings());
          },
          title: '나의 여행',
          showSettingsButton: true,
        ),
        backgroundColor: AppColors.homeBackground,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.white,
                onRefresh: onRefresh,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: MyPageProfileHeader(
                        user: state.user,
                        onAction: onAction,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: MyPagePromotionCarousel(
                        promotions: state.promotions,
                        currentIndex: state.currentPromotionIndex,
                        onAction: onAction,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: MyPageServiceSection(
                        categories: state.categories,
                        onAction: onAction,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(height: bottomPadding),
                    ),
                  ],
                ),
              ),
              if (state.isLoading)
                ColoredBox(
                  color: AppColors.black.withValues(alpha: 0.3),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
