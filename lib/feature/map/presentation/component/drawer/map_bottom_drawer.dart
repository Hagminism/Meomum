import 'package:flutter/material.dart';
import 'package:meomum/core/domain/model/commercial_store/commercial_store.dart';
import 'package:meomum/feature/map/presentation/component/drawer/map_bottom_drawer_controls.dart';
import 'package:meomum/feature/map/presentation/component/drawer/map_bottom_drawer_sheet.dart';
import 'package:meomum/feature/map/presentation/model/map_category.dart';

/// 지도 화면 하단에서 드로어와 플로팅 컨트롤의 배치를 조정합니다.
class MapBottomDrawer extends StatefulWidget {
  final List<CommercialStore> stores;
  final MapCategory? selectedCategory;
  final bool isResearchEnabled;
  final bool isResearchLoading;
  final void Function(MapCategory category) onCategoryPressed;
  final void Function() onCurrentLocationPressed;
  final void Function() onResearchPressed;
  final void Function(CommercialStore store) onStoreSelected;

  const MapBottomDrawer({
    super.key,
    required this.stores,
    required this.selectedCategory,
    required this.isResearchEnabled,
    required this.isResearchLoading,
    required this.onCategoryPressed,
    required this.onCurrentLocationPressed,
    required this.onResearchPressed,
    required this.onStoreSelected,
  });

  @override
  State<MapBottomDrawer> createState() => _MapBottomDrawerState();
}

class _MapBottomDrawerState extends State<MapBottomDrawer> {
  static const double _collapsedContentHeight = 68;
  static const double _bottomNavigationHeight = 96;
  static const double _searchBarHeight = 50;
  static const double _researchButtonTopSpacing = 8;
  static const double _expandedTopSpacing = 16;
  static const double _floatingButtonHeight = 40;
  static const double _floatingButtonSpacing = 9;

  /// 드로어가 차지하는 화면 비율을 추적합니다.
  final DraggableScrollableController _drawerController =
      DraggableScrollableController();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final safeAreaPadding = MediaQuery.paddingOf(context);

        // 축소 상태에서는 카테고리 영역과 하단 내비게이션 영역이
        // 모두 보이도록 높이를 확보합니다.
        final collapsedHeight =
            _collapsedContentHeight + _bottomNavigationHeight;

        // 확장 상태에서도 상단 검색창과 드로어 사이의 간격을 유지합니다.
        final expandedTop =
            safeAreaPadding.top + _searchBarHeight + _expandedTopSpacing;
        final expandedHeight = availableHeight - expandedTop;

        // DraggableScrollableSheet는 높이를 화면 비율로 받으므로
        // 계산된 픽셀 높이를 비율로 변환합니다.
        final maxChildSize = (expandedHeight / availableHeight).clamp(
          0.01,
          1.0,
        );
        final minChildSize = (collapsedHeight / availableHeight).clamp(
          0.01,
          maxChildSize,
        );

        // 드로어와 플로팅 컨트롤을 분리해
        // controller 알림이 드로어 자체를 빌드 중 갱신하지 않도록 합니다.
        return Stack(
          children: [
            Positioned.fill(
              child: MapBottomDrawerSheet(
                controller: _drawerController,
                initialChildSize: minChildSize,
                minChildSize: minChildSize,
                maxChildSize: maxChildSize,
                bottomPadding: _bottomNavigationHeight,
                isLoading: widget.isResearchLoading,
                stores: widget.stores,
                selectedCategory: widget.selectedCategory,
                onCategoryPressed: widget.onCategoryPressed,
                onStoreSelected: widget.onStoreSelected,
              ),
            ),
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _drawerController,
                builder: (context, child) {
                  final currentChildSize = _drawerController.isAttached
                      ? _drawerController.size.clamp(
                          minChildSize,
                          maxChildSize,
                        )
                      : minChildSize;
                  final currentDrawerHeight =
                      availableHeight * currentChildSize;
                  final currentDrawerTop =
                      availableHeight - currentDrawerHeight;

                  // 드로어가 플로팅 컨트롤 영역까지 확장되면
                  // 겹침을 방지하기 위해 컨트롤을 숨깁니다.
                  final controlsVisible =
                      currentDrawerTop >
                      expandedTop +
                          _floatingButtonHeight +
                          _floatingButtonSpacing;

                  return MapBottomDrawerControls(
                    isVisible: controlsVisible,
                    isResearchEnabled: widget.isResearchEnabled,
                    isResearchLoading: widget.isResearchLoading,
                    currentLocationBottom:
                        currentDrawerHeight + _floatingButtonSpacing,
                    researchButtonTop:
                        safeAreaPadding.top +
                        _searchBarHeight +
                        _researchButtonTopSpacing,
                    controlHeight: _floatingButtonHeight,
                    onCurrentLocationPressed: widget.onCurrentLocationPressed,
                    onResearchPressed: widget.onResearchPressed,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _drawerController.dispose();
    super.dispose();
  }
}
