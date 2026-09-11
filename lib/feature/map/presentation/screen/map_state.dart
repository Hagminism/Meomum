import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meomum/core/domain/model/commercial_store/commercial_store.dart';
import 'package:meomum/feature/map/presentation/model/map_category.dart';

part 'map_state.freezed.dart';

@freezed
abstract class MapState with _$MapState {
  const MapState._();

  const factory MapState({
    @Default(false) bool isMapReady,
    @Default(false) bool isLoadingNearbyStores,
    @Default(false) bool isResearchButtonEnabled,
    @Default(<CommercialStore>[]) List<CommercialStore> nearbyStores,
    MapCategory? selectedCategory,
  }) = _MapState;

  /// 선택된 카테고리에 해당하는 상가 목록을 반환합니다.
  List<CommercialStore> get visibleStores {
    final category = selectedCategory;
    if (category == null) {
      return nearbyStores;
    }

    return nearbyStores
        .where((store) {
          return category.containsIndsLclsCd(store.industryLargeCode);
        })
        .toList(growable: false);
  }
}
