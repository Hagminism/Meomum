import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meomum/core/domain/model/tour_spot/tour_spot.dart';
import 'package:meomum/feature/map/presentation/model/map_category.dart';

part 'map_state.freezed.dart';

@freezed
abstract class MapState with _$MapState {
  const MapState._();

  const factory MapState({
    @Default(false) bool isMapReady,
    @Default(false) bool isLoadingNearbyTourSpots,
    @Default(false) bool isResearchButtonEnabled,
    @Default(<TourSpot>[]) List<TourSpot> nearbyTourSpots,
    MapCategory? selectedCategory,
  }) = _MapState;


  /// 선택된 카테고리에 해당하는 관광정보 목록을 반환합니다.
  List<TourSpot> get visibleTourSpots {
    final category = selectedCategory;
    if (category == null) {
      return nearbyTourSpots;
    }

    return nearbyTourSpots
        .where((tourSpot) {
      return category.containsContentTypeId(tourSpot.contentTypeId);
    })
        .toList(growable: false);
  }
}