import 'package:flutter/material.dart';
import 'package:meomum/core/domain/model/commercial_store/commercial_store.dart';
import 'package:meomum/feature/map/presentation/component/drawer/map_category_filter_bar.dart';
import 'package:meomum/feature/map/presentation/component/drawer/map_store_list_item.dart';
import 'package:meomum/feature/map/presentation/model/map_category.dart';
import 'package:meomum/ui/app_colors.dart';

/// 드래그로 높이를 조절할 수 있는 하단 서랍과 카테고리 목록을 표시합니다.
class MapBottomDrawerSheet extends StatelessWidget {
  final DraggableScrollableController controller;
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;
  final double bottomPadding;
  final bool isLoading;
  final List<CommercialStore> stores;
  final MapCategory? selectedCategory;
  final void Function(MapCategory category) onCategoryPressed;
  final void Function(CommercialStore store) onStoreSelected;

  const MapBottomDrawerSheet({
    super.key,
    required this.controller,
    required this.initialChildSize,
    required this.minChildSize,
    required this.maxChildSize,
    required this.bottomPadding,
    required this.isLoading,
    required this.stores,
    required this.selectedCategory,
    required this.onCategoryPressed,
    required this.onStoreSelected,
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
            color: AppColors.homeBackground,
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
                      color: AppColors.homeBackground,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              MapCategoryFilterBar(
                selectedCategory: selectedCategory,
                onCategoryPressed: onCategoryPressed,
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 13,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '가까운 매장이 먼저 표시됩니다.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontFamily: 'Pretendard',
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 20, 16, 24),
                  child: Semantics(
                    label: '주변 매장을 불러오는 중입니다',
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                )
              else if (stores.isEmpty)
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 20, 16, 24),
                  child: Text(
                    '현재 위치 주변에 매장이 없습니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.feedContentText,
                      fontFamily: 'Pretendard',
                      fontSize: 15,
                    ),
                  ),
                )
              else
                ...stores.map(
                  (store) => MapStoreListItem(
                    store: store,
                    onTap: () => onStoreSelected(store),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
