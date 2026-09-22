import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meomum/core/data/repository/location/location_repository_impl.dart';
import 'package:meomum/core/domain/model/commercial_store/commercial_store.dart';
import 'package:meomum/core/domain/model/location/geo_location.dart';
import 'package:meomum/core/presentation/component/app_snackbar.dart';
import 'package:meomum/core/routing/routes.dart';
import 'package:meomum/core/utils/result.dart';
import 'package:meomum/feature/map/presentation/screen/map_action.dart';
import 'package:meomum/feature/map/presentation/screen/map_event.dart';
import 'package:meomum/feature/map/presentation/screen/map_screen.dart';
import 'package:meomum/feature/map/presentation/screen/map_state.dart';
import 'package:meomum/feature/map/presentation/screen/map_view_model.dart';
import 'package:meomum/feature/map/presentation/util/store_marker_manager.dart';

class MapScreenRoot extends ConsumerStatefulWidget {
  const MapScreenRoot({super.key});

  @override
  ConsumerState<MapScreenRoot> createState() => _MapScreenRootState();
}

class _MapScreenRootState extends ConsumerState<MapScreenRoot> {
  static const double defaultLatitude = 37.5666;
  static const double defaultLongitude = 126.979;
  static const double _initialZoom = 14;
  static const double _clusterMergeDistanceDp = 80;

  StreamSubscription<MapEvent>? _eventSubscription;

  // Naver 관련 위젯 및 마커 매니저
  late final StoreMarkerManager _markerManager;
  Widget? _mapView;
  NaverMapController? _mapController;
  List<CommercialStore>? _selectedClusterStores;
  Offset? _selectedClusterOffset;

  /// tracking mode를 변경 중인지 여부를 나타냅니다.
  bool _isUpdatingLocationTracking = false;

  @override
  void initState() {
    super.initState();

    _markerManager = StoreMarkerManager(
      onStoreTapped: _openStoreDetail,
      onClusterTapped: _showClusterStores,
    );
    _mapView = _createMapView();

    ref.listenManual<MapState>(mapViewModelProvider, _handleMapStateChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = ref.read(mapViewModelProvider.notifier);

      _eventSubscription = viewModel.eventStream.listen((MapEvent event) {
        if (!mounted) return;

        switch (event) {
          case ShowMessage(:final message):
            AppSnackBar.showInfo(context, message);
          case ShowError(:final message):
            AppSnackBar.showError(context, message);
        }
      });
    });
  }

  /// 실제로 표시되는 마커 ID가 변경된 경우에만 지도 오버레이를 동기화합니다.
  void _handleMapStateChanged(MapState? previous, MapState next) {
    final previousStores = previous?.visibleStores;
    final nextStores = next.visibleStores;

    if (previousStores != null &&
        !_hasDifferentMarkerIds(previousStores, nextStores)) {
      return;
    }

    unawaited(_markerManager.updateStores(nextStores));
  }

  bool _hasDifferentMarkerIds(
    List<CommercialStore> previous,
    List<CommercialStore> next,
  ) {
    final previousIds = previous.map((store) => store.id).toSet();
    final nextIds = next.map((store) => store.id).toSet();

    return previousIds.length != nextIds.length ||
        !previousIds.containsAll(nextIds);
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
      clusterOptions: NaverMapClusteringOptions(
        mergeStrategy: const NClusterMergeStrategy(
          maxMergeableScreenDistance: _clusterMergeDistanceDp,
          willMergedScreenDistance: {
            NInclusiveRange(0, 10): 80,
            NInclusiveRange(11, 14): 50,
            NInclusiveRange(15, 17): 30,
            NInclusiveRange(18, 21): 15,
          },
        ),
        clusterMarkerBuilder: _configureClusterMarker,
      ),
      onMapTapped: (_, _) {
        _dismissClusterSelection();
      },
      onMapReady: (controller) {
        _mapController = controller;
        _markerManager.setController(controller);
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

    AppSnackBar.showError(context, message);
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

    return MapScreen(
      mapView: _mapView ?? _createMapView(),
      state: state,
      onStoreSelected: _openStoreDetail,
      selectedClusterStores: _selectedClusterStores,
      selectedClusterOffset: _selectedClusterOffset,
      onClusterSelectionDismissed: _dismissClusterSelection,
      onAction: (action) {
        switch (action) {
          case MapReady():
            break;
          case SearchBarPressed():
            context.push('${Routes.map}/${Routes.mapSearch}');
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

  void _configureClusterMarker(
    NClusterInfo info,
    NClusterMarker clusterMarker,
  ) {
    _markerManager.configureClusterMarker(info, clusterMarker);
  }

  Future<void> _showClusterStores(
    List<CommercialStore> stores,
    NLatLng position,
  ) async {
    final controller = _mapController;
    if (controller == null || !mounted || stores.length < 2) return;

    final screenPosition = await controller.latLngToScreenLocation(position);
    if (!mounted) return;

    setState(() {
      _selectedClusterStores = stores;
      _selectedClusterOffset = Offset(screenPosition.x, screenPosition.y);
    });
  }

  void _dismissClusterSelection() {
    if (_selectedClusterStores == null && _selectedClusterOffset == null) {
      return;
    }

    if (!mounted) return;

    setState(() {
      _selectedClusterStores = null;
      _selectedClusterOffset = null;
    });
  }

  void _openStoreDetail(CommercialStore store) {
    _dismissClusterSelection();
    context.push(Routes.storeDetailLocation(store));
  }

  /// 현위치 기준 상가 재검색을 실시합니다.
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
          AppSnackBar.showError(context, message);
      }
    } finally {
      _isUpdatingLocationTracking = false;
    }
  }

  @override
  void dispose() {
    _markerManager.detachController();
    _eventSubscription?.cancel();
    super.dispose();
  }
}
