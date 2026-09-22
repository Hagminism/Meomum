import 'dart:io';

import 'package:meomum/core/utils/result.dart';
import 'package:meomum/feature/community/domain/model/community_place.dart';
import 'package:meomum/feature/community/domain/model/community_post.dart';
import 'package:meomum/feature/community/domain/model/community_post_image.dart';
import 'package:meomum/feature/community/domain/model/enum/community_category.dart';

abstract interface class CommunityPostRepository {
  Future<Result<List<CommunityPost>>> getPosts({
    required String upperRegion,
    required String lowerRegion,
    int limit = 20,
    DateTime? cursor,
  });

  Future<Result<List<CommunityPost>>> getMyPosts({
    int limit = 20,
    DateTime? cursor,
  });

  Future<Result<List<CommunityPost>>> getLikedPosts({
    int limit = 20,
    DateTime? cursor,
  });

  Future<Result<List<CommunityPost>>> getLatestPostsWithImages({
    int limit = 20,
    DateTime? cursor,
  });

  Future<Result<CommunityPost>> getPostById({
    required String postId,
  });

  Future<Result<CommunityPost>> createPost({
    required String upperRegion,
    required String lowerRegion,
    required CommunityCategory category,
    required String title,
    required String content,
    List<File> imageFiles = const [],
    CommunityPlace? place,
  });

  Future<Result<CommunityPost>> createJobPost({
    required String upperRegion,
    required String lowerRegion,
    required String title,
    required String content,
    String? wageType,
    double? wageAmount,
    String? workingTime,
    DateTime? recruitmentDeadline,
    required bool isAlwaysRecruiting,
    List<File> imageFiles = const [],
    CommunityPlace? place,
  });

  Future<Result<bool>> updatePost({
    required String postId,
    required String upperRegion,
    required String lowerRegion,
    required CommunityCategory category,
    required String title,
    required String content,
    List<CommunityPostImage> existingImages = const [],
    List<File> newImageFiles = const [],
    CommunityPlace? place,
  });

  Future<Result<bool>> updateJobPost({
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
    List<CommunityPostImage> existingImages = const [],
    List<File> newImageFiles = const [],
    CommunityPlace? place,
  });

  Future<Result<bool>> deletePost({
    required String postId,
  });

  Future<Result<bool>> toggleLike({
    required String postId,
  });
}
