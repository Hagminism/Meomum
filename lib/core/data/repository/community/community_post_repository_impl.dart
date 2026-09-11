import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/core/data/data_source/community/community_post_data_source.dart';
import 'package:meomum/core/data/data_source/community/community_post_data_source_impl.dart';
import 'package:meomum/core/data/dto/community/community_post_dto.dart';
import 'package:meomum/core/data/mapper/community/community_post_mapper.dart';
import 'package:meomum/core/domain/repository/community/community_post_repository.dart';
import 'package:meomum/core/utils/result.dart';
import 'package:meomum/feature/community/domain/model/community_place.dart';
import 'package:meomum/feature/community/domain/model/community_post.dart';
import 'package:meomum/feature/community/domain/model/community_post_image.dart';
import 'package:meomum/feature/community/domain/model/enum/community_category.dart';

class CommunityPostRepositoryImpl implements CommunityPostRepository {
  final CommunityPostDataSource dataSource;

  CommunityPostRepositoryImpl({
    required this.dataSource,
  });

  @override
  Future<Result<List<CommunityPost>>> getPosts({
    required String upperRegion,
    required String lowerRegion,
    int limit = 20,
    DateTime? cursor,
  }) async {
    final result = await dataSource.getPosts(
      upperRegion: upperRegion,
      lowerRegion: lowerRegion,
      limit: limit,
      cursor: cursor,
    );

    return switch (result) {
      Success(data: final dtoList) => Result.success(
        dtoList
            .map(
              (CommunityPostDto dto) => dto.toModel(
                currentUserId: dataSource.currentUserId,
              ),
            )
            .toList(),
      ),
      Failure(message: final msg) => Result.failure(msg),
    };
  }

  @override
  Future<Result<List<CommunityPost>>> getMyPosts({
    int limit = 20,
    DateTime? cursor,
  }) async {
    final result = await dataSource.getMyPosts(
      limit: limit,
      cursor: cursor,
    );

    return switch (result) {
      Success(data: final dtoList) => Result.success(
        dtoList
            .map(
              (CommunityPostDto dto) => dto.toModel(
                currentUserId: dataSource.currentUserId,
              ),
            )
            .toList(),
      ),
      Failure(message: final msg) => Result.failure(msg),
    };
  }

  @override
  Future<Result<List<CommunityPost>>> getLatestPostsWithImages({
    int limit = 20,
    DateTime? cursor,
  }) async {
    final result = await dataSource.getLatestPostsWithImages(
      limit: limit,
      cursor: cursor,
    );

    return switch (result) {
      Success(data: final dtoList) => Result.success(
        dtoList
            .map(
              (CommunityPostDto dto) => dto.toModel(
                currentUserId: dataSource.currentUserId,
              ),
            )
            .toList(),
      ),
      Failure(message: final msg) => Result.failure(msg),
    };
  }

  @override
  Future<Result<CommunityPost>> getPostById({
    required String postId,
  }) async {
    final result = await dataSource.getPostById(postId: postId);

    return switch (result) {
      Success(data: final dto) => Result.success(
        dto.toModel(currentUserId: dataSource.currentUserId),
      ),
      Failure(message: final msg) => Result.failure(msg),
    };
  }

  @override
  Future<Result<CommunityPost>> createPost({
    required String upperRegion,
    required String lowerRegion,
    required CommunityCategory category,
    required String title,
    required String content,
    List<File> imageFiles = const [],
    CommunityPlace? place,
  }) async {
    // Storage 업로드가 DB 저장보다 먼저 진행되므로, 이후 실패에 대비해 업로드 목록을 보관합니다.
    List<CommunityUploadedImage> uploadedImages = [];

    if (imageFiles.isNotEmpty) {
      final uploadResult = await dataSource.uploadImages(files: imageFiles);
      switch (uploadResult) {
        case Success(data: final images):
          uploadedImages = images;
        case Failure(message: final msg):
          return Result.failure(msg);
      }
    }

    final postResult = await dataSource.createPost(
      upperRegion: upperRegion,
      lowerRegion: lowerRegion,
      category: category.name,
      title: title,
      content: content,
      images: uploadedImages,
      place: place,
    );

    return switch (postResult) {
      Success(data: final postId) => _getCreatedPost(postId),
      Failure(message: final msg) => _cleanupAndReturnFailure<CommunityPost>(
        uploadedImages: uploadedImages,
        message: msg,
      ),
    };
  }

  @override
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
  }) async {
    // 기존 이미지와 새 업로드 이미지를 합쳐 하나의 수정 RPC에 전달합니다.
    List<CommunityUploadedImage> uploadedImages = [];

    if (newImageFiles.isNotEmpty) {
      final uploadResult = await dataSource.uploadImages(files: newImageFiles);
      switch (uploadResult) {
        case Success(data: final images):
          uploadedImages = images;
        case Failure(message: final msg):
          return Result.failure(msg);
      }
    }

    final retainedImages = existingImages
        .map(
          (CommunityPostImage image) => CommunityUploadedImage(
            storagePath: image.storagePath,
            publicUrl: image.publicUrl,
          ),
        )
        .toList(growable: false);
    final finalImages = [...retainedImages, ...uploadedImages];

    final updateResult = await dataSource.updatePost(
      postId: postId,
      upperRegion: upperRegion,
      lowerRegion: lowerRegion,
      category: category.name,
      title: title,
      content: content,
      images: finalImages,
      place: place,
    );

    switch (updateResult) {
      case Success(data: final update):
        // DB 반영이 끝난 뒤에만 삭제된 기존 Storage 파일을 정리합니다.
        await _cleanupRemovedImages(update.removedStoragePaths);
        return const Result.success(true);
      case Failure(message: final msg):
        return _cleanupAndReturnFailure<bool>(
          uploadedImages: uploadedImages,
          message: msg,
        );
    }
  }

  Future<Result<CommunityPost>> _getCreatedPost(String postId) async {
    final result = await getPostById(postId: postId);

    return switch (result) {
      Success() => result,
      Failure(message: final msg) => Result.failure(
        '게시글은 저장되었지만 목록에 반영하지 못했습니다: $msg',
      ),
    };
  }

  Future<void> _cleanupRemovedImages(List<String> storagePaths) async {
    if (storagePaths.isEmpty) return;

    // Storage 정리는 DB 트랜잭션과 분리된 보상 작업이며, 실패하면 재시도 큐 상태를 갱신합니다.
    final cleanupResult = await dataSource.deleteImages(
      storagePaths: storagePaths,
    );
    switch (cleanupResult) {
      case Success():
        await dataSource.completeImageCleanup(storagePaths: storagePaths);
      case Failure(message: final message):
        await dataSource.recordImageCleanupFailure(
          storagePaths: storagePaths,
          message: message,
        );
    }
  }

  Future<Result<T>> _cleanupAndReturnFailure<T>({
    required List<CommunityUploadedImage> uploadedImages,
    required String message,
  }) async {
    if (uploadedImages.isNotEmpty) {
      // 게시글 저장에 실패한 새 업로드 파일은 참조가 없으므로 즉시 삭제합니다.
      final cleanupResult = await dataSource.deleteImages(
        storagePaths: uploadedImages
            .map((CommunityUploadedImage image) => image.storagePath)
            .toList(growable: false),
      );

      if (cleanupResult case Failure(message: final cleanupMessage)) {
        // 즉시 삭제까지 실패하면 다음 앱 실행·재개 시 정리하도록 큐에 등록합니다.
        final storagePaths = uploadedImages
            .map((CommunityUploadedImage image) => image.storagePath)
            .toList(growable: false);
        final enqueueResult = await dataSource.enqueueImageCleanup(
          storagePaths: storagePaths,
        );
        return switch (enqueueResult) {
          Success() => Result.failure(
            '$message 업로드한 이미지 정리에도 실패했습니다: $cleanupMessage',
          ),
          Failure(message: final enqueueMessage) => Result.failure(
            '$message 업로드한 이미지 정리와 재시도 등록에 실패했습니다: '
            '$cleanupMessage ($enqueueMessage)',
          ),
        };
      }
    }

    return Result.failure(message);
  }

  @override
  Future<Result<bool>> toggleLike({
    required String postId,
  }) {
    return dataSource.toggleLike(
      postId: postId,
    );
  }

  @override
  Future<Result<bool>> retryPendingImageCleanup() async {
    // 앱 생명주기 이벤트에서 호출되어 만료된 큐 항목의 Storage 정리를 재개합니다.
    final pendingResult = await dataSource.getPendingImageCleanup();

    return switch (pendingResult) {
      Failure(message: final message) => Result.failure(message),
      Success(data: final items) when items.isEmpty => const Result.success(
        true,
      ),
      Success(data: final items) => _retryImageCleanup(
        items.map((item) => item.storagePath).toList(growable: false),
      ),
    };
  }

  Future<Result<bool>> _retryImageCleanup(List<String> storagePaths) async {
    // 삭제 성공 시 큐에서 제거하고, 실패 시 다음 재시도 시각과 오류를 기록합니다.
    final cleanupResult = await dataSource.deleteImages(
      storagePaths: storagePaths,
    );

    return switch (cleanupResult) {
      Success() => dataSource.completeImageCleanup(storagePaths: storagePaths),
      Failure(message: final message) => _recordCleanupFailure(
        storagePaths: storagePaths,
        message: message,
      ),
    };
  }

  Future<Result<bool>> _recordCleanupFailure({
    required List<String> storagePaths,
    required String message,
  }) async {
    final result = await dataSource.recordImageCleanupFailure(
      storagePaths: storagePaths,
      message: message,
    );

    return switch (result) {
      Success() => Result.failure(message),
      Failure(message: final recordMessage) => Result.failure(
        '$message 재시도 기록에도 실패했습니다: $recordMessage',
      ),
    };
  }
}

final communityPostRepositoryProvider = Provider<CommunityPostRepository>((
  Ref ref,
) {
  return CommunityPostRepositoryImpl(
    dataSource: ref.watch(communityPostDataSourceProvider),
  );
});
