import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/feature/map/presentation/screen/map_action.dart';
import 'package:meomum/feature/map/presentation/screen/map_event.dart';
import 'package:meomum/feature/map/presentation/screen/map_screen.dart';
import 'package:meomum/feature/map/presentation/screen/map_view_model.dart';

class MapScreenRoot extends ConsumerStatefulWidget {
  const MapScreenRoot({super.key});

  @override
  ConsumerState<MapScreenRoot> createState() => _MapScreenRootState();
}

class _MapScreenRootState extends ConsumerState<MapScreenRoot> {
  static const NLatLng _initialTarget = NLatLng(37.5666, 126.979);
  static const double _initialZoom = 14;

  StreamSubscription<MapEvent>? _eventSubscription;
  Widget? _mapView;

  @override
  void initState() {
    super.initState();

    _mapView = _createMapView();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = ref.read(mapViewModelProvider.notifier);

      _eventSubscription = viewModel.eventStream.listen((MapEvent event) {
        if (!mounted) return;

        switch (event) {
          case ShowMessage(:final message):
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
        }
      });
    });
  }

  Widget _createMapView() {
    return NaverMap(
      options: NaverMapViewOptions(
        contentPadding: EdgeInsets.only(bottom: 80),
        locationButtonEnable: true,
        initialCameraPosition: const NCameraPosition(
          target: _initialTarget,
          zoom: _initialZoom,
        ),
      ),
      onMapReady: (_) {
        ref
            .read(mapViewModelProvider.notifier)
            .onAction(const MapAction.mapReady());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mapViewModelProvider);

    return MapScreen(
      state: state,
      mapView: _mapView ?? _createMapView(),
    );
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }
}
