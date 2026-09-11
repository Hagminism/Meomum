import 'package:meomum/core/data/dto/community/community_post_dto.dart';
import 'package:meomum/feature/community/domain/model/community_place.dart';
import 'package:meomum/feature/community/domain/model/community_post.dart';
import 'package:meomum/feature/community/domain/model/community_post_image.dart';
import 'package:meomum/feature/community/domain/model/enum/community_category.dart';

extension CommunityPostDtoMapper on CommunityPostDto {
  CommunityPost toModel({
    String? currentUserId,
  }) {
    // Supabase DTO와 관계 조회 결과를 화면에서 사용하는 게시글 도메인 모델로 변환합니다.
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

    // DB의 sort_order를 기준으로 정렬해 목록과 수정 화면에서 이미지 순서를 동일하게 유지합니다.
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
    // 수정 시 기존 Storage 파일을 식별할 수 있도록 경로·URL·순서를 함께 보존합니다.
    final resolvedImages = linkedImages
        .map((Map<String, dynamic> image) {
          final storagePath = image['storage_path'];
          final publicUrl = image['public_url'];
          if (storagePath is! String ||
              publicUrl is! String ||
              storagePath.isEmpty ||
              publicUrl.isEmpty) {
            return null;
          }

          return CommunityPostImage(
            storagePath: storagePath,
            publicUrl: publicUrl,
            sortOrder: (image['sort_order'] as num?)?.toInt() ?? 0,
          );
        })
        .whereType<CommunityPostImage>()
        .toList(growable: false);

    // 서버에 아직 정의되지 않은 카테고리는 기본 게시판으로 안전하게 대체합니다.
    final resolvedCategory = CommunityCategory.values.firstWhere(
      (CommunityCategory c) => c.name == category,
      orElse: () => CommunityCategory.free,
    );

    final bool isUserLiked;
    if (currentUserId != null) {
      // 로그인 상태에서는 현재 계정의 좋아요 행만 확인합니다.
      isUserLiked = postLikes.any((like) {
        if (like is Map<String, dynamic>) {
          return like['account_id'] == currentUserId;
        }
        return false;
      });
    } else {
      // 현재 계정 정보가 없으면 조회된 좋아요 관계의 존재 여부를 사용합니다.
      isUserLiked = postLikes.isNotEmpty;
    }

    CommunityPlace? place;
    if (placeName != null && placeName!.isNotEmpty) {
      // 위치 이름이 있는 경우에만 위치 객체를 생성합니다.
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
      images: resolvedImages,
      profileImageUrl: profileImageUrl,
      place: place,
    );
  }
}
