import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_region.freezed.dart';
part 'community_region.g.dart';

@freezed
abstract class CommunityRegion with _$CommunityRegion {
  const factory CommunityRegion({
    required String upperRegion,
    required String lowerRegion,
  }) = _CommunityRegion;

  factory CommunityRegion.fromJson(Map<String, dynamic> json) =>
      _$CommunityRegionFromJson(json);
}
