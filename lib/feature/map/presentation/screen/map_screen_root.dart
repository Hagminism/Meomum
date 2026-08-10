import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/core/data/repository/location/location_repository_impl.dart';
import 'package:meomum/core/domain/model/location/geo_location.dart';
import 'package:meomum/core/utils/result.dart';
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
  static const double defaultLatitude = 37.5666;
  static const double defaultLongitude = 126.979;
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
        locationButtonEnable: true,
        logoMargin: const EdgeInsets.only(
          left: 12,
          right: 12,
          top: 16,
          bottom: 92,
        ),
        initialCameraPosition: NCameraPosition(
          target: NLatLng(defaultLatitude, defaultLongitude),
          zoom: _initialZoom,
        ),
      ),
      onMapReady: (controller) {
        unawaited(_initializeMapCamera(controller));
      },
    );
  }

  // 사용자 위치가 화면 중앙에 오도록 카메라 초기화
  Future<void> _initializeMapCamera(NaverMapController controller) async {
    final target = await _resolveInitialMapTarget();

    if (!mounted) return;

    await controller.updateCamera(
      NCameraUpdate.withParams(
        target: NLatLng(target.latitude, target.longitude),
        zoom: _initialZoom,
      ),
    );

    if (!mounted) return;

    ref
        .read(mapViewModelProvider.notifier)
        .onAction(const MapAction.mapReady());
  }

  // 사용자에게 위치 권한 요청 + 사용자 위치 좌표 반환
  // 실패 시 기본 위치(서울시청) 반환
  Future<GeoLocation> _resolveInitialMapTarget() async {
    final result = await ref
        .read(locationRepositoryProvider)
        .getCurrentLocation();

    return switch (result) {
      Success(:final GeoLocation data) => data,
      Failure() => const GeoLocation(
        latitude: defaultLatitude,
        longitude: defaultLongitude,
      ),
    };
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
