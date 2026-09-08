import 'package:meomum/core/data/dto/community/community_post_dto.dart';
import 'package:meomum/feature/community/domain/model/community_place.dart';
import 'package:meomum/feature/community/domain/model/community_post.dart';
import 'package:meomum/feature/community/domain/model/enum/community_category.dart';

extension CommunityPostDtoMapper on CommunityPostDto {
  CommunityPost toModel({
    String? currentUserId,
  }) {
    final parsedCreatedAt = DateTime.tryParse(createdAt) ?? DateTime.now();

    final profile = profiles;
    final nickname = (profile != null && profile['nickname'] is String)
        ? profile['nickname'] as String
        : '동네이웃';
    final profileImageUrl =
        (profile != null && profile['profile_image_url'] is String)
        ? profile['profile_image_url'] as String
        : null;
    final profileUpperRegion =
        (profile != null && profile['upper_region'] is String)
        ? profile['upper_region'] as String
        : null;
    final profileLowerRegion =
        (profile != null && profile['lower_region'] is String)
        ? profile['lower_region'] as String
        : null;
    final profileRegion = [
      profileUpperRegion,
      profileLowerRegion,
    ].whereType<String>().where((String region) => region.isNotEmpty).join(' ');

    final linkedImages = postImages.whereType<Map<String, dynamic>>().toList()
      ..sort(
        (left, right) => ((left['sort_order'] as num?)?.toInt() ?? 0).compareTo(
          (right['sort_order'] as num?)?.toInt() ?? 0,
        ),
      );
    final resolvedImageUrls = linkedImages
        .map((Map<String, dynamic> image) => image['public_url'])
        .whereType<String>()
        .where((String url) => url.isNotEmpty)
        .toList(growable: false);

    final resolvedCategory = CommunityCategory.values.firstWhere(
      (CommunityCategory c) => c.name == category,
      orElse: () => CommunityCategory.free,
    );

    final bool isUserLiked;
    if (currentUserId != null) {
      isUserLiked = postLikes.any((like) {
        if (like is Map<String, dynamic>) {
          return like['account_id'] == currentUserId;
        }
        return false;
      });
    } else {
      isUserLiked = postLikes.isNotEmpty;
    }

    CommunityPlace? place;
    if (placeName != null && placeName!.isNotEmpty) {
      place = CommunityPlace(
        name: placeName!,
        latitude: placeLatitude ?? 0.0,
        longitude: placeLongitude ?? 0.0,
        address: placeAddress ?? '',
        roadAddress: placeRoadAddress ?? '',
        category: placeCategory ?? '',
      );
    }

    return CommunityPost(
      id: id,
      authorId: authorId,
      upperRegion: upperRegion,
      lowerRegion: lowerRegion,
      nickname: nickname.isNotEmpty ? nickname : '동네이웃',
      neighborhood: profileRegion.isNotEmpty ? profileRegion : '동네이웃',
      createdAt: parsedCreatedAt,
      category: resolvedCategory,
      title: title,
      content: content,
      likeCount: likeCount,
      commentCount: commentCount,
      isVerified: false,
      isLiked: isUserLiked,
      imageUrls: resolvedImageUrls,
      profileImageUrl: profileImageUrl,
      place: place,
    );
  }
}
