import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meomum/feature/my_page/presentation/component/my_page_current_stay_card.dart';
import 'package:meomum/feature/my_page/presentation/component/my_page_profile_header.dart';
import 'package:meomum/feature/my_page/presentation/component/my_page_service_section.dart';
import 'package:meomum/feature/my_page/presentation/component/my_page_stay_history_item.dart';
import 'package:meomum/feature/my_page/presentation/screen/my_page_action.dart';
import 'package:meomum/feature/my_page/presentation/screen/my_page_state.dart';
import 'package:meomum/ui/app_colors.dart';

class MyPageScreen extends StatelessWidget {
  final MyPageState state;
  final void Function(MyPageAction) onAction;

  const MyPageScreen({
    super.key,
    required this.state,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom + 88;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.homeBackground,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: MyPageProfileHeader(
                        user: state.user,
                        onAction: onAction,
                      ),
                    ),
                    if (state.currentStay != null)
                      SliverToBoxAdapter(
                        child: MyPageCurrentStayCard(
                          currentStay: state.currentStay!,
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
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
                        child: Text(
                          '머문 기록',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1,
                            color: AppColors.feedContentText,
                          ),
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          return MyPageStayHistoryItem(
                            item: state.stayHistories[index],
                            onAction: onAction,
                          );
                        },
                        childCount: state.stayHistories.length,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16, 24, 16, bottomPadding),
                        child: OutlinedButton(
                          onPressed: state.isLoading
                              ? null
                              : () {
                                  onAction(const MyPageAction.tapLogout());
                                },
                          child: const Text('로그아웃'),
                        ),
                      ),
                    ),
                  ],
                ),
                if (state.isLoading)
                  ColoredBox(
                    color: AppColors.black.withValues(alpha: 0.3),
                    child: const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
