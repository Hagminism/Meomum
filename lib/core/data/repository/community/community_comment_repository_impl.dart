// The public constructor parameters intentionally initialize private dependencies.
// ignore_for_file: prefer_initializing_formals

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/core/data/data_source/community/community_comment_data_source.dart';
import 'package:meomum/core/data/data_source/community/community_comment_data_source_impl.dart';
import 'package:meomum/core/data/data_source/community/community_comment_uploaded_image.dart';
import 'package:meomum/core/data/dto/community/community_comment_dto.dart';
import 'package:meomum/core/data/mapper/community/community_comment_mapper.dart';
import 'package:meomum/core/data/repository/auth/auth_repository_impl.dart';
import 'package:meomum/core/data/repository/storage_cleanup/storage_cleanup_repository_impl.dart';
import 'package:meomum/core/data/storage/storage_bucket.dart';
import 'package:meomum/core/domain/repository/auth/auth_repository.dart';
import 'package:meomum/core/domain/repository/community/community_comment_repository.dart';
import 'package:meomum/core/domain/repository/storage_cleanup/storage_cleanup_repository.dart';
import 'package:meomum/core/utils/result.dart';
import 'package:meomum/feature/community/domain/model/community_comment.dart';

class CommunityCommentRepositoryImpl implements CommunityCommentRepository {
  final CommunityCommentDataSource _dataSource;
  final AuthRepository _authRepository;
  final StorageCleanupRepository _storageCleanupRepository;

  CommunityCommentRepositoryImpl({
    required CommunityCommentDataSource dataSource,
    required AuthRepository authRepository,
    required StorageCleanupRepository storageCleanupRepository,
  }) : _dataSource = dataSource,
       _authRepository = authRepository,
       _storageCleanupRepository = storageCleanupRepository;

  @override
  Future<Result<List<CommunityComment>>> getComments({
    required String postId,
  }) async {
    final result = await _dataSource.getComments(postId: postId);
    return switch (result) {
      Success(data: final dtos) => Result.success(_mapComments(dtos)),
      Failure(message: final message) => Result.failure(message),
    };
  }

  @override
  Future<Result<List<CommunityComment>>> getMyComments({
    int limit = 20,
    DateTime? cursor,
  }) async {
    final accountId = _authRepository.currentUser?.id;
    if (accountId == null) {
      return const Result.failure('로그인이 필요합니다.');
    }
    final result = await _dataSource.getMyComments(
      accountId: accountId,
      limit: limit,
      cursor: cursor,
    );
    return switch (result) {
      Success(data: final dtos) => Result.success(_mapMyComments(dtos)),
      Failure(message: final message) => Result.failure(message),
    };
  }

  @override
  Future<Result<bool>> createComment({
    required String postId,
    String? parentId,
    required String content,
    File? imageFile,
  }) async {
    final accountId = _authRepository.currentUser?.id;
    if (accountId == null) {
      return const Result.failure('로그인이 필요합니다.');
    }
    final trimmedContent = content.trim();
    if (trimmedContent.isEmpty) {
      return const Result.failure('댓글 내용을 입력해주세요.');
    }
    if (trimmedContent.length > 1000) {
      return const Result.failure('댓글은 1,000자 이하로 입력해주세요.');
    }

    CommunityCommentUploadedImage? uploadedImage;
    if (imageFile != null) {
      final uploadResult = await _dataSource.uploadImage(
        accountId: accountId,
        file: imageFile,
      );
      switch (uploadResult) {
        case Success(data: final image):
          uploadedImage = image;
        case Failure(message: final message):
          return Result.failure(message);
      }
    }

    final result = await _dataSource.createComment(
      postId: postId,
      parentId: parentId,
      content: trimmedContent,
      image: uploadedImage,
    );
    return switch (result) {
      Success() => const Result.success(true),
      Failure(message: final message) => _cleanupAndFail(
        uploadedImage: uploadedImage,
        message: message,
      ),
    };
  }

  @override
  Future<Result<bool>> updateComment({
    required String commentId,
    required String content,
    String? storagePath,
    String? imageUrl,
  }) {
    final accountId = _authRepository.currentUser?.id;
    if (accountId == null) {
      return Future.value(const Result.failure('로그인이 필요합니다.'));
    }
    return _dataSource.updateComment(
      commentId: commentId,
      content: content.trim(),
      storagePath: storagePath,
      imageUrl: imageUrl,
    );
  }

  @override
  Future<Result<bool>> deleteComment({required String commentId}) {
    if (_authRepository.currentUser == null) {
      return Future.value(const Result.failure('로그인이 필요합니다.'));
    }
    return _dataSource.deleteComment(commentId: commentId);
  }

  @override
  Future<Result<bool>> toggleLike({required String commentId}) {
    if (_authRepository.currentUser == null) {
      return Future.value(const Result.failure('로그인이 필요합니다.'));
    }
    return _dataSource.toggleLike(commentId: commentId);
  }

  List<CommunityComment> _mapComments(List<CommunityCommentDto> dtos) {
    final comments = _mapDtos(dtos);
    final replyCounts = <String, int>{};
    for (final comment in comments) {
      final parentId = comment.parentId;
      if (parentId != null) {
        replyCounts[parentId] = (replyCounts[parentId] ?? 0) + 1;
      }
    }
    final commentsWithReplyCounts = comments
        .map(
          (CommunityComment comment) => comment.copyWith(
            replyCount: replyCounts[comment.id] ?? 0,
          ),
        )
        .toList(growable: false);

    if (commentsWithReplyCounts.isEmpty ||
        commentsWithReplyCounts.every((CommunityComment item) {
          return item.parentId == null;
        })) {
      return commentsWithReplyCounts;
    }

    final roots = commentsWithReplyCounts
        .where((CommunityComment comment) => comment.parentId == null)
        .toList(growable: false);
    final repliesByRoot = <String, List<CommunityComment>>{};
    for (final reply in commentsWithReplyCounts.where((
      CommunityComment comment,
    ) {
      return comment.parentId != null;
    })) {
      repliesByRoot.putIfAbsent(reply.parentId!, () => []).add(reply);
    }
    return [
      for (final root in roots) ...[
        root,
        ...?repliesByRoot[root.id],
      ],
    ];
  }

  List<CommunityComment> _mapMyComments(List<CommunityCommentDto> dtos) {
    return _mapDtos(dtos);
  }

  List<CommunityComment> _mapDtos(List<CommunityCommentDto> dtos) {
    return dtos
        .map(
          (CommunityCommentDto dto) => dto.toModel(
            currentUserId: _authRepository.currentUser?.id,
          ),
        )
        .toList(growable: false);
  }

  Future<Result<bool>> _cleanupAndFail({
    required CommunityCommentUploadedImage? uploadedImage,
    required String message,
  }) async {
    if (uploadedImage == null) {
      return Result.failure(message);
    }
    final cleanupResult = await _storageCleanupRepository.enqueue(
      bucketName: StorageBucket.communityImages,
      storagePaths: [uploadedImage.storagePath],
    );
    if (cleanupResult case Failure(message: final cleanupMessage)) {
      return Result.failure('$message 이미지 정리 등록에 실패했습니다: $cleanupMessage');
    }
    return Result.failure(message);
  }
}

final communityCommentRepositoryProvider = Provider<CommunityCommentRepository>(
  (Ref ref) {
    return CommunityCommentRepositoryImpl(
      dataSource: ref.watch(communityCommentDataSourceProvider),
      authRepository: ref.watch(authRepositoryProvider),
      storageCleanupRepository: ref.watch(storageCleanupRepositoryProvider),
    );
  },
);
