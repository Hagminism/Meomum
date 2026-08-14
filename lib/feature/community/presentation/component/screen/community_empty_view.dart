import 'package:flutter/material.dart';
import 'package:meomum/ui/app_colors.dart';

class CommunityEmptyView extends StatelessWidget {
  final String regionLabel;

  const CommunityEmptyView({
    super.key,
    required this.regionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.forum_outlined,
              size: 48,
              color: AppColors.unselectedItem,
            ),
            const SizedBox(height: 12),
            Text(
              '$regionLabel에 아직 등록된 글이 없어요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.communityMetaText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
