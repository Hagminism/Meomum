import 'package:flutter/material.dart';
import 'package:meomum/ui/app_colors.dart';

class CommunityJobApiError extends StatelessWidget {
  final String message;

  const CommunityJobApiError({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8ED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1DFBE)),
      ),
      child: Text(
        '관광인 채용정보를 불러오지 못했어요.\n$message',
        style: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 13,
          height: 1.45,
          color: AppColors.communityText,
        ),
      ),
    );
  }
}
