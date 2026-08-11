import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/core/data/repository/tour_info/tour_info_repository_impl.dart';
import 'package:meomum/core/domain/model/location/geo_location.dart';
import 'package:meomum/core/utils/result.dart';
import 'package:meomum/feature/map/presentation/screen/map_action.dart';
import 'package:meomum/feature/map/presentation/screen/map_event.dart';
import 'package:meomum/feature/map/presentation/screen/map_state.dart';

class MapViewModel extends Notifier<MapState> {
  // 검색 반경
  static const int _nearbySearchRadiusMeter = 1000;
  // 재검색 버튼 디바운스 설정 시간
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
        state = state.copyWith(
          isMapReady: true,
          isResearchButtonEnabled: false,
        );
        _loadNearbyTourSpots(location);
      case ResearchButtonPressed():
      case SearchBarPressed():
        break;
    }
  }

  void researchAt(GeoLocation location) {
    // 재검색 버튼이 활성화 되어있거나 이미 가게를 찾는 중이면 리턴
    if (!state.isResearchButtonEnabled || state.isLoadingNearbyTourSpots) {
      return;
    }

    _researchCooldownTimer?.cancel();

    state = state.copyWith(isResearchButtonEnabled: false);

    _researchCooldownTimer = Timer(_researchCooldownDuration, () {
      state = state.copyWith(isResearchButtonEnabled: true);
    });

    _loadNearbyTourSpots(location);
  }

  Future<void> _loadNearbyTourSpots(GeoLocation location) async {
    state = state.copyWith(isLoadingNearbyTourSpots: true);

    final result = await ref
        .read(tourInfoRepositoryProvider)
        .getNearbyTourSpots(
          location: location,
          radius: _nearbySearchRadiusMeter,
        );

    switch (result) {
      case Success(:final data):
        state = state.copyWith(
          isLoadingNearbyTourSpots: false,
          nearbyTourSpots: data,
        );
        _validateCooldown();
      case Failure(:final message):
        state = state.copyWith(isLoadingNearbyTourSpots: false);
        _validateCooldown();
        _eventController.add(MapEvent.showError(message));
    }
  }

  // 타이머가 활성화 되어있지 않으면 재검색 버튼을 활성화
  void _validateCooldown() {
    if (_researchCooldownTimer?.isActive ?? false) return;

    state = state.copyWith(isResearchButtonEnabled: true);
  }
}

final mapViewModelProvider =
    NotifierProvider.autoDispose<MapViewModel, MapState>(
      MapViewModel.new,
    );
