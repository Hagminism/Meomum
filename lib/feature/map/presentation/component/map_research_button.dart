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
      child: Material(
        color: (isEnabled && !isLoading)
            ? AppColors.primary
            : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(30),
        elevation: 2,
        shadowColor: AppColors.black.withValues(alpha: 0.2),
        child: InkWell(
          onTap: (isEnabled && !isLoading) ? onTap : null,
          borderRadius: BorderRadius.circular(30),
          child: SizedBox(
            width: 151,
            height: 40,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isLoading) ...[
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '이 위치에서 재검색',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          height: 1,
                          color: (isEnabled && !isLoading)
                              ? AppColors.white
                              : AppColors.textSecondary,
                        ),
                      ),
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
