import 'package:flutter/material.dart';
import 'package:meomum/feature/my_page_detail/domain/model/enum/my_page_feed_tab.dart';
import 'package:meomum/ui/app_colors.dart';

class MyPageDetailTabSwitch extends StatelessWidget {
  final MyPageFeedTab selectedTab;
  final void Function(MyPageFeedTab) onTabPressed;

  const MyPageDetailTabSwitch({
    super.key,
    required this.selectedTab,
    required this.onTabPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        height: 42,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            for (final tab in MyPageFeedTab.values)
              Expanded(
                child: GestureDetector(
                  onTap: () => onTabPressed(tab),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    decoration: BoxDecoration(
                      color: selectedTab == tab ? AppColors.white : null,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                      child: Text(tab.label),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
