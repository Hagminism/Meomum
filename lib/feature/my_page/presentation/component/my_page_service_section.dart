import 'package:flutter/material.dart';
import 'package:meomum/core/domain/model/category/category.dart';
import 'package:meomum/core/presentation/component/category_item.dart';
import 'package:meomum/feature/my_page/presentation/screen/my_page_action.dart';
import 'package:meomum/ui/app_colors.dart';

class MyPageServiceSection extends StatelessWidget {
  final List<Category> categories;
  final void Function(MyPageAction) onAction;

  const MyPageServiceSection({
    super.key,
    required this.categories,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '모든 서비스',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1,
              color: AppColors.feedContentText,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 0,
              childAspectRatio: 73.75 / 82,
            ),
            itemCount: categories.length,
            itemBuilder: (BuildContext context, int index) {
              final category = categories[index];

              return Center(
                child: CategoryItem(
                  category: category,
                  onTap: (String id) {
                    onAction(MyPageAction.tapCategory(id));
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
