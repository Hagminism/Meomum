import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meomum/core/domain/model/location/geo_location.dart';

part 'map_action.freezed.dart';

@freezed
sealed class MapAction with _$MapAction {
  const factory MapAction.mapReady(GeoLocation location) = MapReady;
  const factory MapAction.researchButtonPressed() = ResearchButtonPressed;
  const factory MapAction.searchBarPressed() = SearchBarPressed;
}
