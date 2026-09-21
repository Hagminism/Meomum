import 'package:flutter/material.dart';
import 'package:meomum/ui/app_colors.dart';

class CommunityJobSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showSourceNotice;

  const CommunityJobSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showSourceNotice = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.communityText,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12,
                      color: AppColors.communityMetaText,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
