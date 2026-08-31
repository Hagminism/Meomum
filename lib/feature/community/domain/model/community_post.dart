import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meomum/core/utils/extension/time_ago_extension.dart';
import 'package:meomum/feature/community/domain/model/enum/community_category.dart';
import 'package:meomum/feature/community/domain/model/community_place.dart';
import 'package:meomum/feature/community/domain/model/community_region.dart';

part 'community_post.freezed.dart';
part 'community_post.g.dart';

@freezed
abstract class CommunityPost with _$CommunityPost {
  const CommunityPost._();

  const factory CommunityPost({
    required String id,
    required String authorId,
    required String upperRegion,
    required String lowerRegion,
    required String nickname,
    @Default('동네이웃') String neighborhood,
    required DateTime createdAt,
    required CommunityCategory category,
    required String title,
    required String content,
    @Default(0) int likeCount,
    @Default(0) int commentCount,
    @Default(false) bool isVerified,
    @Default(false) bool isLiked,
    @Default([]) List<String> imageUrls,
    String? profileImageUrl,
    CommunityPlace? place,
  }) = _CommunityPost;

  String get timeLabel => createdAt.toTimeAgo();

  CommunityRegion get region => CommunityRegion(
        upperRegion: upperRegion,
        lowerRegion: lowerRegion,
      );

  factory CommunityPost.fromJson(Map<String, dynamic> json) =>
      _$CommunityPostFromJson(json);
}
