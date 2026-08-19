import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/core/data/repository/commercial_store/commercial_store_repository_impl.dart';
import 'package:meomum/core/domain/model/location/geo_location.dart';
import 'package:meomum/core/utils/result.dart';
import 'package:meomum/feature/map/presentation/model/map_category.dart';
import 'package:meomum/feature/map/presentation/screen/map_action.dart';
import 'package:meomum/feature/map/presentation/screen/map_event.dart';
import 'package:meomum/feature/map/presentation/screen/map_state.dart';

class MapViewModel extends Notifier<MapState> {
  /// 검색 반경
  static const int _nearbySearchRadiusMeter = 1000;

  /// 재검색 버튼 디바운스 설정 시간
  static const Duration _researchCooldownDuration = Duration(seconds: 3);

  Timer? _researchCooldownTimer;

  @override
  MapState build() {
    ref.onDispose(() {
      _researchCooldownTimer?.cancel();
      _eventController.close();
    });

    return const MapState();
  }

  final StreamController<MapEvent> _eventController =
      StreamController<MapEvent>.broadcast();

  Stream<MapEvent> get eventStream => _eventController.stream;

  void onAction(MapAction action) {
    switch (action) {
      case MapReady(:final location):
        _initialize(location);
      case ResearchButtonPressed():
      case SearchBarPressed():
      case CurrentLocationPressed():
        break;
      case CategoryFilterPressed(:final category):
        _toggleCategory(category);
    }
  }

  void _initialize(GeoLocation location) {
    state = state.copyWith(isMapReady: true, isResearchButtonEnabled: false);

    _loadNearbyStores(location);
  }

  /// 현 위치 주변의 상가 정보를 불러옵니다.
  Future<void> _loadNearbyStores(GeoLocation location) async {
    state = state.copyWith(isLoadingNearbyStores: true);

    try {
      final result = await ref
          .read(commercialStoreRepositoryProvider)
          .getNearbyStores(
            location: location,
            radius: _nearbySearchRadiusMeter,
          );

      if (!ref.mounted) return;

      switch (result) {
        case Success(:final data):
          state = state.copyWith(
            isLoadingNearbyStores: false,
            nearbyStores: data,
          );
        case Failure(:final message):
          state = state.copyWith(isLoadingNearbyStores: false);
          _eventController.add(MapEvent.showError(message));
      }
    } catch (error) {
      if (!ref.mounted) return;

      state = state.copyWith(isLoadingNearbyStores: false);
      _eventController.add(MapEvent.showError('주변 상가를 가져오지 못했습니다. ($error)'));
    } finally {
      if (ref.mounted) {
        _validateCooldown();
      }
    }
  }

  /// 타이머가 완료되었으면 재검색 버튼을 활성화합니다.
  void _validateCooldown() {
    if (_researchCooldownTimer?.isActive ?? false) return;

    state = state.copyWith(isResearchButtonEnabled: true);
  }

  /// 재검색 버튼을 비활성화한 후, 현 위치 주변의 상가 정보를 불러옵니다.
  /// 재검색 버튼이 활성화 되어있거나 이미 가게를 찾는 중인 경우 리턴합니다.
  void researchAt(GeoLocation location) {
    if (!state.isResearchButtonEnabled || state.isLoadingNearbyStores) {
      return;
    }

    _researchCooldownTimer?.cancel();

    state = state.copyWith(isResearchButtonEnabled: false);

    _researchCooldownTimer = Timer(_researchCooldownDuration, () {
      state = state.copyWith(isResearchButtonEnabled: true);
    });

    _loadNearbyStores(location);
  }

  void _toggleCategory(MapCategory category) {
    state = state.copyWith(
      selectedCategory: (state.selectedCategory == category) ? null : category,
    );
  }
}

final mapViewModelProvider =
    NotifierProvider.autoDispose<MapViewModel, MapState>(MapViewModel.new);
