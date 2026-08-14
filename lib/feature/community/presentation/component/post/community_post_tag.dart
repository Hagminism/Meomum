import 'package:flutter/material.dart';
import 'package:meomum/ui/app_colors.dart';

class CommunityPostTag extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final IconData? icon;

  const CommunityPostTag({
    super.key,
    required this.label,
    required this.backgroundColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: AppColors.communityText,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1,
                color: AppColors.communityText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
