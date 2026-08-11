import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meomum/core/domain/model/tour_spot/tour_spot.dart';

part 'map_state.freezed.dart';

@freezed
abstract class MapState with _$MapState {
  const factory MapState({
    @Default(false) bool isMapReady,
    @Default(false) bool isLoadingNearbyTourSpots,
    @Default(false) bool isResearchButtonEnabled,
    @Default(<TourSpot>[]) List<TourSpot> nearbyTourSpots,
  }) = _MapState;
}
