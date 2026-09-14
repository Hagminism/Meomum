import 'package:flutter/material.dart';
import 'package:meomum/ui/app_colors.dart';

class AppLoadingOverlay extends StatelessWidget {
  final String message;

  const AppLoadingOverlay({
    super.key,
    this.message = '잠시만 기다려주세요',
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        type: MaterialType.transparency,
        child: Semantics(
          liveRegion: true,
          label: message,
          child: ColoredBox(
            color: AppColors.black.withValues(alpha: 0.18),
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.homeBackground,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2,
                        constraints: BoxConstraints(minHeight: 22, minWidth: 22),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        message,
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.1,
                          color: AppColors.communityText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
