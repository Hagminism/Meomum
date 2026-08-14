import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meomum/feature/community/domain/model/enum/community_category.dart';
import 'package:meomum/feature/community/domain/model/community_place.dart';
import 'package:meomum/feature/community/domain/model/community_region.dart';

part 'community_post.freezed.dart';
part 'community_post.g.dart';

@freezed
abstract class CommunityPost with _$CommunityPost {
  const factory CommunityPost({
    required String id,
    required CommunityRegion region,
    required String nickname,
    required String neighborhood,
    required String timeLabel,
    required CommunityCategory category,
    required String title,
    required String content,
    required int likeCount,
    required int commentCount,
    @Default(false) bool isVerified,
    @Default(false) bool isLiked,
    @Default([]) List<String> imageUrls,
    String? profileImageUrl,
    CommunityPlace? place,
  }) = _CommunityPost;

  factory CommunityPost.fromJson(Map<String, dynamic> json) =>
      _$CommunityPostFromJson(json);
}
