import 'package:freezed_annotation/freezed_annotation.dart';

part 'geo_location.freezed.dart';

@freezed
abstract class GeoLocation with _$GeoLocation {
  const factory GeoLocation({
    required double latitude,
    required double longitude,
  }) = _GeoLocation;
}
