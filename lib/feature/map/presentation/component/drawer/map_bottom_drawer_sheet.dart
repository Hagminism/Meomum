import 'package:flutter/material.dart';
import 'package:meomum/feature/map/presentation/component/drawer/map_category_filter_bar.dart';
import 'package:meomum/feature/map/presentation/model/map_category.dart';
import 'package:meomum/ui/app_colors.dart';

/// 드래그로 높이를 조절할 수 있는 하단 서랍과 카테고리 목록을 표시합니다.
class MapBottomDrawerSheet extends StatelessWidget {
  final DraggableScrollableController controller;
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;
  final double bottomPadding;
  final MapCategory? selectedCategory;
  final void Function(MapCategory category) onCategoryPressed;

  const MapBottomDrawerSheet({
    super.key,
    required this.controller,
    required this.initialChildSize,
    required this.minChildSize,
    required this.maxChildSize,
    required this.bottomPadding,
    required this.selectedCategory,
    required this.onCategoryPressed,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: controller,
      initialChildSize: initialChildSize,
      minChildSize: minChildSize,
      maxChildSize: maxChildSize,

      // 드래그를 마치면 서랍을 최소 또는 최대 높이로 정렬합니다.
      snap: true,
      snapAnimationDuration: const Duration(milliseconds: 220),
      builder: (context, scrollController) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.white,
            border: const Border(
              top: BorderSide(color: AppColors.divider),
            ),
          ),

          // Sheet에서 제공하는 컨트롤러를 연결해
          // 서랍 드래그와 내부 스크롤이 이어지도록 합니다.
          child: ListView(
            controller: scrollController,
            physics: const ClampingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: EdgeInsets.only(bottom: bottomPadding),
            children: [
              SizedBox(
                height: 16,
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFA1A1A2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              MapCategoryFilterBar(
                selectedCategory: selectedCategory,
                onCategoryPressed: onCategoryPressed,
              ),
            ],
          ),
        );
      },
    );
  }
}
