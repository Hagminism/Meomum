import 'package:flutter/material.dart';
import 'package:meomum/feature/map_search/presentation/component/map_search_retry_button.dart';
import 'package:meomum/ui/app_colors.dart';

class MapSearchErrorView extends StatelessWidget {
  final void Function() onRetry;

  const MapSearchErrorView({
    super.key,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.snackBarError.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColors.snackBarError,
                size: 34,
                semanticLabel: '검색 오류',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '검색을 불러오지 못했어요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.black,
                fontFamily: 'Pretendard',
                fontSize: 17,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '잠시 후 다시 시도해 주세요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontFamily: 'Pretendard',
                fontSize: 14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            MapSearchRetryButton(onTap: onRetry),
          ],
        ),
      ),
    );
  }
}
