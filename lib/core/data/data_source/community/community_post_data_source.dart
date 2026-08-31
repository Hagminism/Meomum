import 'dart:io';

import 'package:meomum/core/data/dto/community/community_post_dto.dart';
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

  Future<Result<List<CommunityUploadedImage>>> uploadImages({
    required List<File> files,
  });

  Future<Result<bool>> deleteImages({
    required List<String> storagePaths,
  });

  Future<Result<bool>> toggleLike({
    required String postId,
    required bool isCurrentlyLiked,
  });

  String? get currentUserId;
}
