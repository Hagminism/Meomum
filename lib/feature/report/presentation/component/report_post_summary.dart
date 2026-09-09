import 'package:flutter/material.dart';
import 'package:meomum/feature/community/domain/model/community_post.dart';
import 'package:meomum/ui/app_colors.dart';

class ReportPostSummary extends StatelessWidget {
  final CommunityPost post;

  const ReportPostSummary({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.inputBorder, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.article_outlined,
            size: 20,
            color: AppColors.hintIcon,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.category.label,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.feedMetaText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  post.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.communityText,
                    height: 1.35,
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
