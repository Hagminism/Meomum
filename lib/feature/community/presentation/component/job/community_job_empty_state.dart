import 'package:flutter/material.dart';
import 'package:meomum/ui/app_colors.dart';

class CommunityJobEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const CommunityJobEmptyState({
    super.key,
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: AppColors.unselectedItem),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.communityMetaText,
            ),
          ),
        ],
      ),
    );
  }
}
