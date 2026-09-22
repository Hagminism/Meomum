import 'package:flutter/material.dart';
import 'package:meomum/feature/my_page/domain/model/my_page_promotion.dart';
import 'package:meomum/feature/my_page/presentation/screen/my_page_action.dart';
import 'package:meomum/ui/app_colors.dart';

class MyPagePromotionCarousel extends StatelessWidget {
  final List<MyPagePromotion> promotions;
  final int currentIndex;
  final void Function(MyPageAction) onAction;

  const MyPagePromotionCarousel({
    super.key,
    required this.promotions,
    required this.currentIndex,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    if (promotions.isEmpty) {
      return const SizedBox.shrink();
    }

    final normalizedIndex = currentIndex.clamp(0, promotions.length - 1);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 2.35,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: PageView.builder(
                itemCount: promotions.length,
                onPageChanged: (int index) {
                  onAction(MyPageAction.changePromotionIndex(index));
                },
                itemBuilder: (BuildContext context, int index) {
                  return _buildPromotionPage(context, promotions[index]);
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Semantics(
            liveRegion: true,
            label: '홍보 배너 ${normalizedIndex + 1} / ${promotions.length}',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(promotions.length, (int index) {
                final isActive = index == normalizedIndex;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isActive ? 16 : 6,
                  height: 6,
                  margin: EdgeInsets.only(
                    right: index == promotions.length - 1 ? 0 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary
                        : AppColors.unselectedItem.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionPage(
    BuildContext context,
    MyPagePromotion promotion,
  ) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          promotion.imageAssetPath,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          errorBuilder:
              (
                BuildContext context,
                Object error,
                StackTrace? stackTrace,
              ) {
                return ColoredBox(color: AppColors.cardBackground);
              },
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xCFFFFFFF),
                Color(0x00FFFFFF),
              ],
              stops: [0.0, 1],
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: 0.58,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 0, 14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    promotion.eyebrow,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    promotion.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    promotion.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.35,
                      color: AppColors.black.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
