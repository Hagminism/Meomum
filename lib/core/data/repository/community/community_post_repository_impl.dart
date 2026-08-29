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
      Failure(message: final msg) => _cleanupAndReturnFailure(
        uploadedImages: uploadedImages,
        message: msg,
      ),
    };
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

  Future<Result<CommunityPost>> _cleanupAndReturnFailure({
    required List<CommunityUploadedImage> uploadedImages,
    required String message,
  }) async {
    if (uploadedImages.isNotEmpty) {
      final cleanupResult = await dataSource.deleteImages(
        storagePaths: uploadedImages
            .map((CommunityUploadedImage image) => image.storagePath)
            .toList(growable: false),
      );

      if (cleanupResult case Failure(message: final cleanupMessage)) {
        return Result.failure(
          '$message 업로드한 이미지 정리에도 실패했습니다: $cleanupMessage',
        );
      }
    }

    return Result.failure(message);
  }

  @override
  Future<Result<bool>> toggleLike({
    required String postId,
    required bool isCurrentlyLiked,
  }) {
    return dataSource.toggleLike(
      postId: postId,
      isCurrentlyLiked: isCurrentlyLiked,
    );
  }
}

final communityPostRepositoryProvider = Provider<CommunityPostRepository>((
  Ref ref,
) {
  return CommunityPostRepositoryImpl(
    dataSource: ref.watch(communityPostDataSourceProvider),
  );
});
