import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_place.freezed.dart';

part 'community_place.g.dart';

@freezed
abstract class CommunityPlace with _$CommunityPlace {
  const factory CommunityPlace({
    required String name,
    required double latitude,
    required double longitude,
    @Default('') String address,
    @Default('') String roadAddress,
    @Default('') String category,
  }) = _CommunityPlace;

  factory CommunityPlace.fromJson(Map<String, Object?> json) =>
      _$CommunityPlaceFromJson(json);
}
