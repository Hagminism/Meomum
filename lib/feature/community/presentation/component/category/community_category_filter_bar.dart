import 'package:flutter/material.dart';
import 'package:meomum/feature/community/domain/model/community_category.dart';
import 'package:meomum/ui/app_colors.dart';

class CommunityCategoryFilterBar extends StatelessWidget {
  final CommunityCategory selectedCategory;
  final void Function(CommunityCategory) onCategoryPressed;

  const CommunityCategoryFilterBar({
    super.key,
    required this.selectedCategory,
    required this.onCategoryPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: CommunityCategory.values.length,
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(width: 8);
        },
        itemBuilder: (BuildContext context, int index) {
          final category = CommunityCategory.values[index];
          final isSelected = category == selectedCategory;

          return Material(
            color: isSelected
                ? AppColors.mapCategoryButtonSelected
                : AppColors.cardBackground,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              onTap: () => onCategoryPressed(category),
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Center(
                  child: Text(
                    category.label,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1,
                      color: isSelected
                          ? AppColors.white
                          : AppColors.communityText,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
