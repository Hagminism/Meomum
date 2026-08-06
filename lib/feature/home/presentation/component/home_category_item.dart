import 'package:flutter/material.dart';
import 'package:meomum/feature/home/domain/model/home_category.dart';
import 'package:meomum/feature/home/presentation/screen/home_action.dart';
import 'package:meomum/ui/app_colors.dart';

class HomeCategoryItem extends StatelessWidget {
  final HomeCategory category;
  final void Function(HomeAction) onAction;

  const HomeCategoryItem({
    super.key,
    required this.category,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onAction(HomeAction.tapCategory(category.id));
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Color(category.backgroundColor),
                borderRadius: BorderRadius.circular(30),
              ),
              clipBehavior: Clip.antiAlias,
              child: category.imageUrl != null
                  ? Image.network(
                      category.imageUrl!,
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
            const SizedBox(height: 10),
            Text(
              category.label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.black,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
