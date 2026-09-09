import 'package:flutter/material.dart';
import 'package:meomum/ui/app_colors.dart';

class MyPageDetailEmptyView extends StatelessWidget {
  final String message;

  const MyPageDetailEmptyView({
    super.key,
    required this.message,
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
      ),
    );
  }
}
