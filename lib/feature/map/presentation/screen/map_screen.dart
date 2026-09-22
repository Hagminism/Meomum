import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:meomum/core/domain/model/commercial_store/commercial_store.dart';
import 'package:meomum/feature/map/presentation/component/drawer/map_bottom_drawer.dart';
import 'package:meomum/feature/map/presentation/component/map_cluster_store_picker.dart';
import 'package:meomum/feature/map/presentation/component/map_search_bar.dart';
import 'package:meomum/feature/map/presentation/screen/map_action.dart';
import 'package:meomum/feature/map/presentation/screen/map_state.dart';
import 'package:meomum/ui/app_colors.dart';

class MapScreen extends StatelessWidget {
  final Widget mapView;
  final MapState state;
  final void Function(MapAction action) onAction;
  final void Function(CommercialStore store) onStoreSelected;
  final List<CommercialStore>? selectedClusterStores;
  final Offset? selectedClusterOffset;
  final void Function() onClusterSelectionDismissed;

  const MapScreen({
    super.key,
    required this.mapView,
    required this.state,
    required this.onAction,
    required this.onStoreSelected,
    required this.selectedClusterStores,
    required this.selectedClusterOffset,
    required this.onClusterSelectionDismissed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          mapView,
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MapSearchBar(
                    onTap: () => onAction(MapAction.searchBarPressed()),
                  ),
                ],
              ),
            ),
          ),
          MapBottomDrawer(
            stores: state.visibleStores,
            selectedCategory: state.selectedCategory,
            isResearchEnabled: state.isResearchButtonEnabled,
            isResearchLoading: state.isLoadingNearbyStores,
            onCategoryPressed: (category) {
              onAction(MapAction.categoryFilterPressed(category));
            },
            onCurrentLocationPressed: () {
              onAction(MapAction.currentLocationPressed());
            },
            onResearchPressed: () {
              onAction(MapAction.researchButtonPressed());
            },
            onStoreSelected: onStoreSelected,
          ),
          _buildClusterStorePicker(),
          if (!state.isMapReady)
            ColoredBox(
              color: AppColors.black.withValues(alpha: 0.3),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildClusterStorePicker() {
    final stores = selectedClusterStores;
    final anchor = selectedClusterOffset;
    if (stores == null || anchor == null) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          const horizontalPadding = 16.0;
          const anchorSpacing = 16.0;
          final panelWidth = math.min(
            240.0,
            math.max(0.0, constraints.maxWidth - horizontalPadding * 2),
          );
          final maxLeft = math.max(
            horizontalPadding,
            constraints.maxWidth - panelWidth - horizontalPadding,
          );
          final preferredLeft = anchor.dx < constraints.maxWidth / 2
              ? anchor.dx + anchorSpacing
              : anchor.dx - panelWidth - anchorSpacing;
          final left = preferredLeft.clamp(
            horizontalPadding,
            maxLeft,
          );
          final panelHeight = MapClusterStorePicker.estimatedHeight(
            stores.length,
          );
          final aboveTop = anchor.dy - panelHeight - anchorSpacing;
          final belowTop = anchor.dy + anchorSpacing;
          final maxTop = math.max(
            horizontalPadding,
            constraints.maxHeight - panelHeight - 196,
          );
          final top = aboveTop >= horizontalPadding
              ? aboveTop
              : belowTop <= maxTop
              ? belowTop
              : maxTop;

          return Stack(
            children: [
              Positioned(
                left: left,
                top: top,
                width: panelWidth,
                child: MapClusterStorePicker(
                  stores: stores,
                  onStoreSelected: onStoreSelected,
                  onDismiss: onClusterSelectionDismissed,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
