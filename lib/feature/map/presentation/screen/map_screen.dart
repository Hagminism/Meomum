import 'package:flutter/material.dart';
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
          if (!state.isMapReady)
            ColoredBox(
              color: AppColors.black.withValues(alpha: 0.3),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: MapSearchBar(
                onTap: () => onAction(MapAction.searchBarPressed()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
