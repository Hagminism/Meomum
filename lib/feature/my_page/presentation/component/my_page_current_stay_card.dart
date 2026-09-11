import 'package:flutter/material.dart';
import 'package:meomum/feature/my_page/domain/model/current_stay.dart';
import 'package:meomum/feature/my_page/presentation/screen/my_page_action.dart';
import 'package:meomum/ui/app_colors.dart';

class MyPageCurrentStayCard extends StatelessWidget {
  final CurrentStay currentStay;
  final void Function(MyPageAction) onAction;

  const MyPageCurrentStayCard({
    super.key,
    required this.currentStay,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                width: 72,
                height: 72,
                color: AppColors.thumbnailPlaceholder,
                child: currentStay.thumbnailUrl != null
                    ? Image.network(
                        currentStay.thumbnailUrl!,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (
                              BuildContext context,
                              Object error,
                              StackTrace? stackTrace,
                            ) {
                              return const SizedBox.shrink();
                            },
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '지금 머무는 중',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1,
                      color: AppColors.currentStayLabel,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentStay.location,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      height: 1,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentStay.dateRange,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1,
                      color: AppColors.feedContentText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentStay.jobType,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1,
                      color: AppColors.feedContentText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentStay.accommodation,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1,
                      color: AppColors.feedContentText,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                onAction(const MyPageAction.tapCurrentStayMenu());
              },
              icon: const Icon(Icons.more_vert, size: 24),
              color: AppColors.black,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 44,
                minHeight: 44,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
