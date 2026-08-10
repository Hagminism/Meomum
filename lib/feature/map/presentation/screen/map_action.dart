import 'package:freezed_annotation/freezed_annotation.dart';

part 'map_action.freezed.dart';

@freezed
sealed class MapAction with _$MapAction {
  const factory MapAction.mapReady() = MapReady;
}
