import 'dart:io';

import 'package:meomum/core/data/data_source/community/community_comment_uploaded_image.dart';
import 'package:meomum/core/data/dto/community/community_comment_dto.dart';
import 'package:meomum/core/utils/result.dart';

abstract interface class CommunityCommentDataSource {
  Future<Result<List<CommunityCommentDto>>> getComments({
    required String postId,
  });

  Future<Result<List<CommunityCommentDto>>> getMyComments({
    required String accountId,
    int limit = 20,
    DateTime? cursor,
  });

  Future<Result<String>> createComment({
    required String postId,
    String? parentId,
    required String content,
    CommunityCommentUploadedImage? image,
  });

  Future<Result<bool>> updateComment({
    required String commentId,
    required String content,
    String? storagePath,
    String? imageUrl,
  });

  Future<Result<bool>> deleteComment({
    required String commentId,
  });

  Future<Result<bool>> toggleLike({
    required String commentId,
  });

  Future<Result<CommunityCommentUploadedImage>> uploadImage({
    required String accountId,
    required File file,
  });
}
