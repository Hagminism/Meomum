import 'package:flutter/material.dart';
import 'package:meomum/feature/map/presentation/component/map_research_button.dart';
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
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 100.0),
                    child: MapResearchButton(
                      isEnabled: state.isResearchButtonEnabled,
                      isLoading: state.isLoadingNearbyTourSpots,
                      onTap: () => onAction(MapAction.researchButtonPressed()),
                    ),
                  ),
                ],
              ),
            ),
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
