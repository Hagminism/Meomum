import 'package:flutter/material.dart';
import 'package:meomum/ui/app_colors.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:meomum/core/domain/model/commercial_store/commercial_store.dart';

/// 네이버 지도 위의 상가 마커(클러스터블 마커) 추가, 삭제 및 동기화를 전담 관리하는 클래스입니다.
class StoreMarkerManager {
  NaverMapController? _controller;
  final Set<String> _currentMarkerIds = <String>{};
  bool _isUpdating = false;
  List<CommercialStore>? _pendingStores;

  StoreMarkerManager();

  /// 네이버 지도 컨트롤러를 연결합니다.
  void setController(NaverMapController controller) {
    _controller = controller;
  }

  /// 컨트롤러 연결을 해제하고 관리 중인 마커 상태를 초기화합니다.
  void detachController() {
    _controller = null;
    _currentMarkerIds.clear();
    _pendingStores = null;
    _isUpdating = false;
  }

  /// 화면에 존재하는 마커를 diffing하여 삭제/추가하고 최신 상가 리스트와 동기화합니다.
  /// iOS에서는 clearOverlays가 클러스터 마커 빌더를 깨뜨리므로 diff 기반 개별 삭제를 수행합니다.
  Future<void> updateStores(List<CommercialStore> stores) async {
    _pendingStores = stores;
    if (_isUpdating) return;

    _isUpdating = true;
    try {
      while (_pendingStores != null) {
        final nextStores = _pendingStores!;
        _pendingStores = null;
        await _syncStores(nextStores);
      }
    } finally {
      _isUpdating = false;
    }
  }

  /// 현재 지도에 렌더링된 마커 목록과 전달받은 상가 목록 간의 차분(Diff)을 계산하여
  /// 불필요한 마커를 삭제하고 새로운 상가 마커를 일괄 추가합니다.
  Future<void> _syncStores(List<CommercialStore> stores) async {
    final controller = _controller;
    if (controller == null) return;

    final nextIds = stores.map((store) => store.id).toSet();
    final idsToRemove = _currentMarkerIds.difference(nextIds);

    // 1. 이전 목록에는 있었으나 새 목록에서 제외된 마커 삭제
    for (final id in idsToRemove) {
      await controller.deleteOverlay(
        NOverlayInfo(type: NOverlayType.clusterableMarker, id: id),
      );
    }

    // 2. 새로 추가된 상가에 대한 클러스터블 마커 생성 및 일괄 추가
    final markersToAdd = stores
        .where((store) => !_currentMarkerIds.contains(store.id))
        .map(
          (store) => NClusterableMarker(
            id: store.id,
            position: NLatLng(store.latitude, store.longitude),
            caption: NOverlayCaption(text: store.name),
            iconTintColor: AppColors.primary,
            size: Size(30, 40),
          ),
        )
        .toSet();

    if (markersToAdd.isNotEmpty) {
      await controller.addOverlayAll(markersToAdd);
    }

    // 3. 현재 관리 중인 마커 ID 집합 갱신
    _currentMarkerIds
      ..clear()
      ..addAll(nextIds);
  }
}
