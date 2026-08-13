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

  // Naver 관련 위젯들
  Widget? _mapView;
  NaverMapController? _mapController;

  /// tracking mode를 변경 중인지 여부를 나타냅니다.
  bool _isUpdatingLocationTracking = false;

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

  /// mapView를 생성합니다.
  Widget _createMapView() {
    return NaverMap(
      options: NaverMapViewOptions(
        logoMargin: const EdgeInsets.only(
          left: 12,
          right: 12,
          top: 16,
          bottom: 96,
        ),
        initialCameraPosition: NCameraPosition(
          target: NLatLng(defaultLatitude, defaultLongitude),
          zoom: _initialZoom,
        ),
      ),
      onMapReady: (controller) {
        _mapController = controller;
        controller.setMyLocationTracker(
          NDefaultMyLocationTracker(
            onPermissionDenied: _handleLocationPermissionDenied,
          ),
        );
        _initializeMapCamera(controller);
      },
    );
  }

  /// 현재 위치 권한 상태를 확인하고 상태에 따른 스낵바를 표시합니다.
  /// 위치 권한 부여를 거부했을 경우에만 실행됩니다.
  void _handleLocationPermissionDenied(bool isForeverDenied) {
    if (!mounted) return;

    final message = isForeverDenied
        ? '위치 권한이 차단되어 있습니다. 설정에서 위치 권한을 허용해 주세요.'
        : '현재 위치를 표시하려면 위치 권한이 필요합니다.';

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  /// 사용자의 현재 위치가 화면 중앙에 오도록 카메라를 조정합니다.
  Future<void> _initializeMapCamera(NaverMapController controller) async {
    final target = await _getInitialMapTarget();

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

  /// 사용자에게 위치 권한을 요청하며, 권한 획득 성공 시 사용자의 현위치 좌표를,
  /// 실패 시 기본 위치(서울시청)를 반환합니다.
  Future<GeoLocation> _getInitialMapTarget() async {
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
    final viewModel = ref.read(mapViewModelProvider.notifier);


    // 관광정보 목록에 변경이 있거나 카테고리가 변경되면,
    // 화면에 표시되는 마커들을 전부 제거하고, 새로 확정된 내용을 기반으로 마커를 재표시합니다.
    ref.listen<MapState>(mapViewModelProvider, (previous, next) {
      final tourSpotsChanged =
          previous?.nearbyTourSpots != next.nearbyTourSpots;
      final categoryChanged =
          previous?.selectedCategory != next.selectedCategory;

      if (tourSpotsChanged || categoryChanged) {
        _updateTourSpotMarkers(next.visibleTourSpots);
      }
    });

    return MapScreen(
      mapView: _mapView ?? _createMapView(),
      state: state,
      onAction: (action) {
        switch (action) {
          case MapReady():
          case SearchBarPressed():
            break;
          case ResearchButtonPressed():
            _handleResearchButtonPressed();
            break;
          case CategoryFilterPressed():
            viewModel.onAction(action);
            break;
          case CurrentLocationPressed():
            _handleCurrentLocationPressed();
            break;
        }
      },
    );
  }

  /// 화면에 존재하는 모든 마커를 제거하고, 새로 확정된 관광정보 리스트를 마커로 표시합니다.
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

  /// 현위치 기준 관광정보 재검색을 실시합니다.
  Future<void> _handleResearchButtonPressed() async {
    final controller = _mapController;
    if (controller == null) return;

    final position = await controller.getCameraPosition();
    if (!mounted) return;

    ref
        .read(mapViewModelProvider.notifier)
        .researchAt(
          GeoLocation(
            latitude: position.target.latitude,
            longitude: position.target.longitude,
          ),
        );
  }

  /// 현재 설정된 지도의 trakcing mode 값에 따라 카메라 이동 여부를 결정합니다.
  Future<void> _handleCurrentLocationPressed() async {
    final controller = _mapController;
    if (controller == null || _isUpdatingLocationTracking) return;

    switch (controller.locationTrackingMode) {
      // 사용자 위치가 중앙에 있는 경우, noFollow 모드로 변경
      case NLocationTrackingMode.follow:
      case NLocationTrackingMode.face:
        controller.setLocationTrackingMode(NLocationTrackingMode.noFollow);
      // 사용자 위치가 중앙이 아닌 경우,
      // 사용자 위치를 중앙으로 재정렬 후 follow 모드로 변경
      case NLocationTrackingMode.none:
      case NLocationTrackingMode.noFollow:
        await _recenterAndChangeTrackingMode(controller);
    }
  }

  /// 사용자의 현재 위치를 조회 후, 해당 위치가 화면의 중심으로 오도록 카메라를 이동시키고
  /// trakcing mode를 follow로 변경합니다.
  Future<void> _recenterAndChangeTrackingMode(
    NaverMapController controller,
  ) async {
    _isUpdatingLocationTracking = true;

    try {
      final result = await ref
          .read(locationRepositoryProvider)
          .getCurrentLocation();
      if (!mounted) return;

      switch (result) {
        case Success(:final GeoLocation data):
          await controller.updateCamera(
            NCameraUpdate.withParams(
              target: NLatLng(data.latitude, data.longitude),
              bearing: 0,
            )..setAnimation(duration: const Duration(milliseconds: 300)),
          );
          if (!mounted) return;

          controller.setLocationTrackingMode(NLocationTrackingMode.follow);
        case Failure(:final message):
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      _isUpdatingLocationTracking = false;
    }
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }
}
