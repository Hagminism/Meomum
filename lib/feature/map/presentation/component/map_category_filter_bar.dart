import 'package:flutter/material.dart';
import 'package:meomum/feature/map/presentation/model/map_category.dart';
import 'package:meomum/ui/app_colors.dart';

class MapCategoryFilterBar extends StatelessWidget {
  final MapCategory? selectedCategory;
  final void Function(MapCategory category) onCategoryPressed;

  const MapCategoryFilterBar({
    super.key,
    required this.selectedCategory,
    required this.onCategoryPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: MapCategory.values.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = MapCategory.values[index];
          final isSelected = selectedCategory == category;

          return Material(
            color: isSelected
                ? AppColors.mapCategoryButtonSelected
                : AppColors.cardBackground,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              onTap: () => onCategoryPressed(category),
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Center(
                  child: Text(
                    category.label,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1,
                      color: isSelected ? AppColors.white : AppColors.black,
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
