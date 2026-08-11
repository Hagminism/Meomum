import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/feature/map/presentation/screen/map_action.dart';
import 'package:meomum/feature/map/presentation/screen/map_event.dart';
import 'package:meomum/feature/map/presentation/screen/map_state.dart';

class MapViewModel extends Notifier<MapState> {
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
      case MapReady():
        state = state.copyWith(isMapReady: true);
      case SearchBarPressed():
        break;
    }
  }
}

final mapViewModelProvider =
    NotifierProvider.autoDispose<MapViewModel, MapState>(
      MapViewModel.new,
    );
