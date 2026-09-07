import 'package:flutter/material.dart';
import 'package:meomum/feature/community/domain/model/enum/community_category.dart';
import 'package:meomum/ui/app_colors.dart';

class CommunityCategorySelectorButton extends StatelessWidget {
  final CommunityCategory selectedCategory;
  final void Function() onTap;

  const CommunityCategorySelectorButton({
    super.key,
    required this.selectedCategory,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
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
          child: Row(
            children: [
              Expanded(
                child: Text(
                  selectedCategory.label,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black,
                  ),
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 24,
                color: AppColors.placeholderText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
