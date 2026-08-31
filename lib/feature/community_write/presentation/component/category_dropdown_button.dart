import 'package:flutter/material.dart';
import 'package:meomum/feature/community/domain/model/enum/community_category.dart';
import 'package:meomum/ui/app_colors.dart';

class CategoryDropdownButton extends StatelessWidget {
  final CommunityCategory selectedCategory;
  final void Function(CommunityCategory) onSelected;

  const CategoryDropdownButton({
    super.key,
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        height: 50,
        width: 120,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.inputBorder,
            width: 1,
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<CommunityCategory>(
            value: selectedCategory,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 24,
              color: AppColors.placeholderText,
            ),
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.black,
            ),
            borderRadius: BorderRadius.circular(8),
            dropdownColor: AppColors.white,
            onChanged: (category) {
              if (category != null) {
                onSelected(category);
              }
            },
            items: CommunityCategory.values.map((category) {
              return DropdownMenuItem<CommunityCategory>(
                value: category,
                child: Text(category.label),
              );
            }).toList(growable: false),
          ),
        ),
      ),
    );
  }
}
