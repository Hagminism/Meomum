import 'package:flutter/material.dart';
import 'package:meomum/ui/app_colors.dart';

class MapResearchButton extends StatelessWidget {
  final bool isEnabled;
  final bool isLoading;
  final void Function() onTap;

  const MapResearchButton({
    super.key,
    required this.isEnabled,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: (isEnabled && !isLoading) ? 1 : 0.45,
      child: Container(
        height: 32,
        decoration: BoxDecoration(
          color: (isEnabled && !isLoading)
              ? AppColors.white
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.1),
              offset: const Offset(0, 4),
              blurRadius: 3,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          child: InkWell(
            onTap: (isEnabled && !isLoading) ? onTap : null,
            borderRadius: BorderRadius.circular(25),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isLoading)
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: (isEnabled && !isLoading)
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    )
                  else
                    Icon(
                      Icons.refresh,
                      size: 18,
                      color: (isEnabled && !isLoading)
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  const SizedBox(width: 6),
                  Text(
                    '이 지역 재검색',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1,
                      color: (isEnabled && !isLoading)
                          ? AppColors.feedContentText
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
