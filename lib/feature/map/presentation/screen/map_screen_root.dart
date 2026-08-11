import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/core/data/repository/location/location_repository_impl.dart';
import 'package:meomum/core/domain/model/location/geo_location.dart';
import 'package:meomum/core/domain/model/tour_spot/tour_spot.dart';
import 'package:meomum/core/utils/result.dart';
import 'package:meomum/feature/map/presentation/screen/map_action.dart';
import 'package:meomum/feature/map/presentation/screen/map_event.dart';
import 'package:meomum/feature/map/presentation/screen/map_screen.dart';
import 'package:meomum/feature/map/presentation/screen/map_state.dart';
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
  NaverMapController? _mapController;

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
          case ShowError(:final message):
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
        _mapController = controller;
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
        .onAction(MapAction.mapReady(target));
  }

  // 조회된 주변 관광정보를 지도 위 마커로 갱신
  Future<void> _updateTourSpotMarkers(List<TourSpot> tourSpots) async {
    final controller = _mapController;
    if (controller == null) return;

    await controller.clearOverlays(type: NOverlayType.marker);

    final markers = tourSpots
        .map(
          (spot) => NMarker(
            id: spot.id,
            position: NLatLng(spot.latitude, spot.longitude),
            caption: NOverlayCaption(text: spot.title),
          ),
        )
        .toSet();

    await controller.addOverlayAll(markers);
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

    ref.listen<MapState>(mapViewModelProvider, (previous, next) {
      if (previous?.nearbyTourSpots != next.nearbyTourSpots) {
        unawaited(_updateTourSpotMarkers(next.nearbyTourSpots));
      }
    });

    return MapScreen(
      mapView: _mapView ?? _createMapView(),
      state: state,
      onAction: (action) {
        switch (action) {
          case MapReady():
          case SearchBarPressed():
            // TODO: 검색 화면 이동 로직은 추후 추가
            break;
        }
      },
    );
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }
}
