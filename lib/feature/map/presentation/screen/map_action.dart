import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meomum/core/domain/model/location/geo_location.dart';
import 'package:meomum/feature/map/presentation/model/map_category.dart';

part 'map_action.freezed.dart';

@freezed
sealed class MapAction with _$MapAction {
  const factory MapAction.mapReady(GeoLocation location) = MapReady;
  const factory MapAction.researchButtonPressed() = ResearchButtonPressed;
  const factory MapAction.searchBarPressed() = SearchBarPressed;
  const factory MapAction.categoryFilterPressed(MapCategory category) =
      CategoryFilterPressed;
  const factory MapAction.currentLocationPressed() = CurrentLocationPressed;
}
