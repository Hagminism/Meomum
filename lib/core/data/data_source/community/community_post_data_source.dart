import 'dart:io';

import 'package:meomum/core/data/dto/community/community_post_dto.dart';
import 'package:meomum/core/data/model/community/community_post_update_result.dart';
import 'package:meomum/core/utils/result.dart';
import 'package:meomum/feature/community/domain/model/community_place.dart';

class CommunityUploadedImage {
  final String storagePath;
  final String publicUrl;

  const CommunityUploadedImage({
    required this.storagePath,
    required this.publicUrl,
  });
}

abstract interface class CommunityPostDataSource {
  Future<Result<List<CommunityPostDto>>> getPosts({
    required String upperRegion,
    required String lowerRegion,
    int limit = 20,
    DateTime? cursor,
  });

  Future<Result<List<CommunityPostDto>>> getMyPosts({
    required String accountId,
    int limit = 20,
    DateTime? cursor,
  });

  Future<Result<List<CommunityPostDto>>> getLikedPosts({
    required String accountId,
    int limit = 20,
    DateTime? cursor,
  });

  Future<Result<List<CommunityPostDto>>> getLatestPostsWithImages({
    int limit = 20,
    DateTime? cursor,
  });

  Future<Result<CommunityPostDto>> getPostById({
    required String postId,
  });

  Future<Result<String>> createPost({
    required String upperRegion,
    required String lowerRegion,
    required String category,
    required String title,
    required String content,
    List<CommunityUploadedImage> images = const [],
    CommunityPlace? place,
  });

  Future<Result<String>> createJobPost({
    required String upperRegion,
    required String lowerRegion,
    required String title,
    required String content,
    String? wageType,
    double? wageAmount,
    String? workingTime,
    DateTime? recruitmentDeadline,
    required bool isAlwaysRecruiting,
    List<CommunityUploadedImage> images = const [],
    CommunityPlace? place,
  });

  Future<Result<CommunityPostUpdateResult>> updatePost({
    required String postId,
    required String upperRegion,
    required String lowerRegion,
    required String category,
    required String title,
    required String content,
    List<CommunityUploadedImage> images = const [],
    CommunityPlace? place,
  });

  Future<Result<CommunityPostUpdateResult>> updateJobPost({
    required String postId,
    required String upperRegion,
    required String lowerRegion,
    required String title,
    required String content,
    String? wageType,
    double? wageAmount,
    String? workingTime,
    DateTime? recruitmentDeadline,
    required bool isAlwaysRecruiting,
    List<CommunityUploadedImage> images = const [],
    CommunityPlace? place,
  });

  Future<Result<List<String>>> deletePost({
    required String postId,
  });

  Future<Result<CommunityUploadedImage>> uploadImage({
    required String accountId,
    required File file,
  });

  Future<Result<bool>> toggleLike({
    required String postId,
  });
}
