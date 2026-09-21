// The public constructor parameter intentionally initializes a private dependency.
// ignore_for_file: prefer_initializing_formals

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/core/data/repository/auth/auth_repository_impl.dart';
import 'package:meomum/core/data/data_source/community/community_post_data_source.dart';
import 'package:meomum/core/data/data_source/community/community_post_data_source_impl.dart';
import 'package:meomum/core/data/dto/community/community_post_dto.dart';
import 'package:meomum/core/data/mapper/community/community_post_mapper.dart';
import 'package:meomum/core/data/storage/storage_bucket.dart';
import 'package:meomum/core/domain/repository/auth/auth_repository.dart';
import 'package:meomum/core/domain/repository/community/community_post_repository.dart';
import 'package:meomum/core/domain/repository/storage_cleanup/storage_cleanup_repository.dart';
import 'package:meomum/core/data/repository/storage_cleanup/storage_cleanup_repository_impl.dart';
import 'package:meomum/core/utils/result.dart';
import 'package:meomum/feature/community/domain/model/community_place.dart';
import 'package:meomum/feature/community/domain/model/community_post.dart';
import 'package:meomum/feature/community/domain/model/community_post_image.dart';
import 'package:meomum/feature/community/domain/model/enum/community_category.dart';

class CommunityPostRepositoryImpl implements CommunityPostRepository {
  final CommunityPostDataSource dataSource;
  final AuthRepository _authRepository;
  final StorageCleanupRepository _storageCleanupRepository;

  CommunityPostRepositoryImpl({
    required this.dataSource,
    required AuthRepository authRepository,
    required StorageCleanupRepository storageCleanupRepository,
  }) : _authRepository = authRepository,
       _storageCleanupRepository = storageCleanupRepository;

  /// 게시글 DTO 목록을 도메인 모델로 변환해 지역·커서 조건에 맞는 목록을 반환합니다.
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
                currentUserId: _currentAccountId,
              ),
            )
            .toList(),
      ),
      Failure(message: final msg) => Result.failure(msg),
    };
  }

  /// 현재 사용자의 게시글 DTO 목록을 도메인 모델로 변환해 반환합니다.
  @override
  Future<Result<List<CommunityPost>>> getMyPosts({
    int limit = 20,
    DateTime? cursor,
  }) async {
    final accountId = _currentAccountId;
    if (accountId == null) {
      return const Result.failure('로그인이 필요합니다.');
    }

    final result = await dataSource.getMyPosts(
      accountId: accountId,
      limit: limit,
      cursor: cursor,
    );

    return switch (result) {
      Success(data: final dtoList) => Result.success(
        dtoList
            .map(
              (CommunityPostDto dto) => dto.toModel(
                currentUserId: _currentAccountId,
              ),
            )
            .toList(),
      ),
      Failure(message: final msg) => Result.failure(msg),
    };
  }

  /// 현재 사용자가 좋아요한 게시글 DTO 목록을 도메인 모델로 변환해 반환합니다.
  @override
  Future<Result<List<CommunityPost>>> getLikedPosts({
    int limit = 20,
    DateTime? cursor,
  }) async {
    final accountId = _currentAccountId;
    if (accountId == null) {
      return const Result.failure('로그인이 필요합니다.');
    }

    final result = await dataSource.getLikedPosts(
      accountId: accountId,
      limit: limit,
      cursor: cursor,
    );

    return switch (result) {
      Success(data: final dtoList) => Result.success(
        dtoList
            .map(
              (CommunityPostDto dto) => dto.toModel(
                currentUserId: _currentAccountId,
              ),
            )
            .toList(),
      ),
      Failure(message: final msg) => Result.failure(msg),
    };
  }

  /// 이미지가 있는 최신 게시글 DTO 목록을 도메인 모델로 변환해 반환합니다.
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
                currentUserId: _currentAccountId,
              ),
            )
            .toList(),
      ),
      Failure(message: final msg) => Result.failure(msg),
    };
  }

  /// 게시글 상세 DTO를 도메인 모델로 변환해 반환합니다.
  @override
  Future<Result<CommunityPost>> getPostById({
    required String postId,
  }) async {
    final result = await dataSource.getPostById(postId: postId);

    return switch (result) {
      Success(data: final dto) => Result.success(
        dto.toModel(currentUserId: _currentAccountId),
      ),
      Failure(message: final msg) => Result.failure(msg),
    };
  }

  /// 이미지를 먼저 업로드한 뒤 게시글을 저장하고, 저장 실패 시 업로드 이미지를 정리 큐에 등록합니다.
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
    final accountId = _currentAccountId;
    if (accountId == null) {
      return const Result.failure('로그인이 필요합니다.');
    }

    // Storage 업로드가 DB 저장보다 먼저 진행되므로, 이후 실패에 대비해 업로드 목록을 보관합니다.
    List<CommunityUploadedImage> uploadedImages = [];

    if (imageFiles.isNotEmpty) {
      final uploadResult = await _uploadImages(
        accountId: accountId,
        files: imageFiles,
      );
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
  }) async {
    final accountId = _currentAccountId;
    if (accountId == null) {
      return const Result.failure('로그인이 필요합니다.');
    }

    List<CommunityUploadedImage> uploadedImages = [];

    if (imageFiles.isNotEmpty) {
      final uploadResult = await _uploadImages(
        accountId: accountId,
        files: imageFiles,
      );
      switch (uploadResult) {
        case Success(data: final images):
          uploadedImages = images;
        case Failure(message: final msg):
          return Result.failure(msg);
      }
    }

    final postResult = await dataSource.createJobPost(
      upperRegion: upperRegion,
      lowerRegion: lowerRegion,
      title: title,
      content: content,
      wageType: wageType,
      wageAmount: wageAmount,
      workingTime: workingTime,
      recruitmentDeadline: recruitmentDeadline,
      isAlwaysRecruiting: isAlwaysRecruiting,
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

  /// 기존 이미지와 새 이미지를 합쳐 게시글을 수정하고, 실패한 새 업로드는 정리 큐에 등록합니다.
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
    final accountId = _currentAccountId;
    if (accountId == null) {
      return const Result.failure('로그인이 필요합니다.');
    }

    // 기존 이미지와 새 업로드 이미지를 합쳐 하나의 수정 RPC에 전달합니다.
    List<CommunityUploadedImage> uploadedImages = [];

    if (newImageFiles.isNotEmpty) {
      final uploadResult = await _uploadImages(
        accountId: accountId,
        files: newImageFiles,
      );
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
      case Success():
        // 삭제된 Storage 파일은 DB RPC가 공통 정리 큐에 등록합니다.
        return const Result.success(true);
      case Failure(message: final msg):
        return _cleanupAndReturnFailure<bool>(
          uploadedImages: uploadedImages,
          message: msg,
        );
    }
  }

  @override
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
  }) async {
    final accountId = _currentAccountId;
    if (accountId == null) {
      return const Result.failure('로그인이 필요합니다.');
    }

    List<CommunityUploadedImage> uploadedImages = [];

    if (newImageFiles.isNotEmpty) {
      final uploadResult = await _uploadImages(
        accountId: accountId,
        files: newImageFiles,
      );
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

    final updateResult = await dataSource.updateJobPost(
      postId: postId,
      upperRegion: upperRegion,
      lowerRegion: lowerRegion,
      title: title,
      content: content,
      wageType: wageType,
      wageAmount: wageAmount,
      workingTime: workingTime,
      recruitmentDeadline: recruitmentDeadline,
      isAlwaysRecruiting: isAlwaysRecruiting,
      images: finalImages,
      place: place,
    );

    switch (updateResult) {
      case Success():
        return const Result.success(true);
      case Failure(message: final msg):
        return _cleanupAndReturnFailure<bool>(
          uploadedImages: uploadedImages,
          message: msg,
        );
    }
  }

  /// 게시글 삭제 RPC를 호출하고 Storage 정리는 서버 큐에 맡깁니다.
  @override
  Future<Result<bool>> deletePost({
    required String postId,
  }) async {
    if (_currentAccountId == null) {
      return const Result.failure('로그인이 필요합니다.');
    }

    final result = await dataSource.deletePost(postId: postId);

    switch (result) {
      case Failure(message: final message):
        return Result.failure(message);
      case Success():
        // 게시글 삭제 RPC가 공통 정리 큐에 삭제 대상 경로를 등록합니다.
        return const Result.success(true);
    }
  }

  /// 이미지 업로드를 순차적으로 진행하고, 중간 실패 시 먼저 업로드된 파일을 정리 큐에 등록합니다.
  Future<Result<List<CommunityUploadedImage>>> _uploadImages({
    required String accountId,
    required List<File> files,
  }) async {
    final uploadedImages = <CommunityUploadedImage>[];

    for (final file in files) {
      final uploadResult = await dataSource.uploadImage(
        accountId: accountId,
        file: file,
      );

      switch (uploadResult) {
        case Success(data: final image):
          uploadedImages.add(image);
        case Failure(message: final message):
          return _cleanupAndReturnFailure<List<CommunityUploadedImage>>(
            uploadedImages: uploadedImages,
            message: message,
          );
      }
    }

    return Result.success(uploadedImages);
  }

  /// 저장된 게시글을 다시 조회해 생성 요청의 최종 도메인 모델을 반환합니다.
  Future<Result<CommunityPost>> _getCreatedPost(String postId) async {
    final result = await getPostById(postId: postId);

    return switch (result) {
      Success() => result,
      Failure(message: final msg) => Result.failure(
        '게시글은 저장되었지만 목록에 반영하지 못했습니다: $msg',
      ),
    };
  }

  /// 게시글 저장 실패를 반환하면서 새로 업로드된 이미지의 서버 정리 등록을 시도합니다.
  Future<Result<T>> _cleanupAndReturnFailure<T>({
    required List<CommunityUploadedImage> uploadedImages,
    required String message,
  }) async {
    if (uploadedImages.isNotEmpty) {
      // 게시글 저장에 실패한 새 업로드 이미지는 공통 큐에서 정리합니다.
      final enqueueResult = await _storageCleanupRepository.enqueue(
        bucketName: StorageBucket.communityImages,
        storagePaths: uploadedImages
            .map((CommunityUploadedImage image) => image.storagePath)
            .toList(growable: false),
      );

      if (enqueueResult case Failure(message: final enqueueMessage)) {
        return Result.failure(
          '$message 업로드한 이미지 정리와 재시도 등록에 실패했습니다: $enqueueMessage',
        );
      }
    }

    return Result.failure(message);
  }

  /// 현재 사용자의 게시글 좋아요 상태 변경을 데이터 소스에 위임합니다.
  @override
  Future<Result<bool>> toggleLike({
    required String postId,
  }) {
    if (_currentAccountId == null) {
      return Future.value(const Result.failure('로그인이 필요합니다.'));
    }

    return dataSource.toggleLike(
      postId: postId,
    );
  }

  /// 현재 인증된 Auth0 계정에 연결된 Supabase `accounts.id`를 반환합니다.
  String? get _currentAccountId => _authRepository.currentUser?.id;
}

final communityPostRepositoryProvider = Provider<CommunityPostRepository>((
  Ref ref,
) {
  return CommunityPostRepositoryImpl(
    dataSource: ref.watch(communityPostDataSourceProvider),
    authRepository: ref.watch(authRepositoryProvider),
    storageCleanupRepository: ref.watch(storageCleanupRepositoryProvider),
  );
});
