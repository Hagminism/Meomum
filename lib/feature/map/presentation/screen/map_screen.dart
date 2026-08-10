import 'package:flutter/material.dart';
import 'package:meomum/feature/map/presentation/screen/map_state.dart';
import 'package:meomum/ui/app_colors.dart';

class MapScreen extends StatelessWidget {
  final MapState state;
  final Widget mapView;

  const MapScreen({
    super.key,
    required this.state,
    required this.mapView,
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
        ],
      ),
    );
  }
}
