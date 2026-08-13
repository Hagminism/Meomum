import 'package:flutter/material.dart';
import 'package:meomum/feature/map/presentation/component/drawer/map_bottom_drawer.dart';
import 'package:meomum/feature/map/presentation/component/map_search_bar.dart';
import 'package:meomum/feature/map/presentation/screen/map_action.dart';
import 'package:meomum/feature/map/presentation/screen/map_state.dart';
import 'package:meomum/ui/app_colors.dart';

class MapScreen extends StatelessWidget {
  final Widget mapView;
  final MapState state;
  final void Function(MapAction action) onAction;

  const MapScreen({
    super.key,
    required this.mapView,
    required this.state,
    required this.onAction,
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
            selectedCategory: state.selectedCategory,
            isResearchEnabled: state.isResearchButtonEnabled,
            isResearchLoading: state.isLoadingNearbyTourSpots,
            onCategoryPressed: (category) {
              onAction(MapAction.categoryFilterPressed(category));
            },
            onCurrentLocationPressed: () {
              onAction(MapAction.currentLocationPressed());
            },
            onResearchPressed: () {
              onAction(MapAction.researchButtonPressed());
            },
          ),
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
}
