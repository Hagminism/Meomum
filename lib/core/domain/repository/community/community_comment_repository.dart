import 'dart:io';

import 'package:meomum/core/utils/result.dart';
import 'package:meomum/feature/community/domain/model/community_comment.dart';

abstract interface class CommunityCommentRepository {
  Future<Result<List<CommunityComment>>> getComments({
    required String postId,
  });

  Future<Result<List<CommunityComment>>> getMyComments({
    int limit = 20,
    DateTime? cursor,
  });

  Future<Result<bool>> createComment({
    required String postId,
    String? parentId,
    required String content,
    File? imageFile,
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
}
