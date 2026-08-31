import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_post_dto.freezed.dart';
part 'community_post_dto.g.dart';

@freezed
abstract class CommunityPostDto with _$CommunityPostDto {
  const factory CommunityPostDto({
    required String id,
    @JsonKey(name: 'author_id') required String authorId,
    @JsonKey(name: 'upper_region') required String upperRegion,
    @JsonKey(name: 'lower_region') required String lowerRegion,
    required String category,
    required String title,
    required String content,
    @JsonKey(name: 'like_count') @Default(0) int likeCount,
    @JsonKey(name: 'comment_count') @Default(0) int commentCount,
    @JsonKey(name: 'place_name') String? placeName,
    @JsonKey(name: 'place_latitude') double? placeLatitude,
    @JsonKey(name: 'place_longitude') double? placeLongitude,
    @JsonKey(name: 'place_address') String? placeAddress,
    @JsonKey(name: 'place_road_address') String? placeRoadAddress,
    @JsonKey(name: 'place_category') String? placeCategory,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    Map<String, dynamic>? profiles,
    @JsonKey(name: 'post_images') @Default([]) List<dynamic> postImages,
    @JsonKey(name: 'post_likes') @Default([]) List<dynamic> postLikes,
  }) = _CommunityPostDto;

  factory CommunityPostDto.fromJson(Map<String, dynamic> json) =>
      _$CommunityPostDtoFromJson(json);
}
