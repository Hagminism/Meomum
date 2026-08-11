import 'package:flutter/material.dart';
import 'package:meomum/feature/my_page/domain/model/stay_history_item.dart';
import 'package:meomum/feature/my_page/presentation/screen/my_page_action.dart';
import 'package:meomum/ui/app_colors.dart';

class MyPageStayHistoryItem extends StatelessWidget {
  final StayHistoryItem item;
  final void Function(MyPageAction) onAction;

  const MyPageStayHistoryItem({
    super.key,
    required this.item,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              width: 60,
              height: 60,
              color: AppColors.thumbnailPlaceholder,
              child: item.thumbnailUrl != null
                  ? Image.network(
                      item.thumbnailUrl!,
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
            child: GestureDetector(
              onTap: () {
                onAction(MyPageAction.tapStayHistory(item.id));
              },
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                    item.dateRange,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
          ),
          IconButton(
            onPressed: () {
              onAction(MyPageAction.tapStayHistoryMenu(item.id));
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
    );
  }
}
