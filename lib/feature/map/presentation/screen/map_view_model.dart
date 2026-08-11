import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/core/data/repository/tour_info/tour_info_repository_impl.dart';
import 'package:meomum/core/domain/model/location/geo_location.dart';
import 'package:meomum/core/utils/result.dart';
import 'package:meomum/feature/map/presentation/screen/map_action.dart';
import 'package:meomum/feature/map/presentation/screen/map_event.dart';
import 'package:meomum/feature/map/presentation/screen/map_state.dart';

class MapViewModel extends Notifier<MapState> {
  static const int _nearbySearchRadiusMeter = 1000;

  @override
  MapState build() {
    ref.onDispose(() => _eventController.close());

    return const MapState();
  }

  final StreamController<MapEvent> _eventController =
      StreamController<MapEvent>.broadcast();

  Stream<MapEvent> get eventStream => _eventController.stream;

  void onAction(MapAction action) {
    switch (action) {
      case MapReady(:final location):
        state = state.copyWith(isMapReady: true);
        _loadNearbyTourSpots(location);
      case SearchBarPressed():
        break;
    }
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
      case Failure(:final message):
        state = state.copyWith(isLoadingNearbyTourSpots: false);
        _eventController.add(MapEvent.showError(message));
    }
  }
}

final mapViewModelProvider =
    NotifierProvider.autoDispose<MapViewModel, MapState>(
      MapViewModel.new,
    );
