import 'package:flutter/material.dart';
import 'package:meomum/feature/home/domain/model/home_banner.dart';
import 'package:meomum/feature/home/presentation/screen/home_action.dart';
import 'package:meomum/ui/app_colors.dart';

class HomeBannerSection extends StatelessWidget {
  final List<HomeBanner> banners;
  final int currentIndex;
  final void Function(HomeAction) onAction;

  const HomeBannerSection({
    super.key,
    required this.banners,
    required this.currentIndex,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    if (banners.isEmpty) {
      return const SizedBox.shrink();
    }

    final topPadding = MediaQuery.paddingOf(context).top;

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: banners.length,
          onPageChanged: (int index) {
            onAction(HomeAction.changeBannerIndex(index));
          },
          itemBuilder: (BuildContext context, int index) {
            return _BannerPage(banner: banners[index]);
          },
        ),
        Positioned(
          left: 12,
          top: topPadding + 20,
          child: Image.asset('assets/app_logo_home.png', width: 110),
        ),
        Positioned(
          left: 24,
          bottom: 28,
          child: Row(
            children: List.generate(banners.length, (int index) {
              final isActive = index == currentIndex;

              return Padding(
                padding: EdgeInsets.only(
                  right: index == banners.length - 1 ? 0 : 8,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isActive ? 12 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.white
                        : AppColors.unselectedItem.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _BannerPage extends StatelessWidget {
  final HomeBanner banner;

  const _BannerPage({
    required this.banner,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(16),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (banner.imageUrl?.startsWith('assets/') ?? false)
            Image.asset(
              alignment: AlignmentGeometry.xy(0, 0.28),
              banner.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder:
                  (BuildContext context, Object error, StackTrace? stackTrace) {
                    return ColoredBox(color: AppColors.black);
                  },
            )
          else if (banner.imageUrl != null)
            Image.network(
              banner.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder:
                  (BuildContext context, Object error, StackTrace? stackTrace) {
                    return ColoredBox(color: AppColors.black);
                  },
            )
          else
            ColoredBox(color: AppColors.black),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.black.withValues(alpha: 0),
                  AppColors.bannerOverlay,
                ],
                stops: const [0.38, 1.0],
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 52,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  banner.eyebrow,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.white,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  banner.title,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  banner.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.white,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
