import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meomum/core/data/data_source/community/community_post_data_source.dart';
import 'package:meomum/core/data/dto/community/community_post_dto.dart';
import 'package:meomum/core/data/repository/community/community_post_repository_impl.dart';
import 'package:meomum/core/domain/enum/auth_provider.dart';
import 'package:meomum/core/domain/model/user/user.dart';
import 'package:meomum/core/domain/repository/auth/auth_repository.dart';
import 'package:meomum/core/domain/repository/community/community_post_repository.dart';
import 'package:meomum/core/domain/repository/storage_cleanup/storage_cleanup_repository.dart';
import 'package:meomum/core/utils/result.dart';
import 'package:meomum/feature/community/domain/model/community_place.dart';
import 'package:meomum/feature/community/domain/model/community_post.dart';
import 'package:meomum/feature/community/domain/model/enum/community_category.dart';

void main() {
  group('CommunityPostRepositoryImpl', () {
    test('현재 계정 ID를 getMyPosts 데이터 소스에 전달한다', () async {
      final dataSource = _FakeCommunityPostDataSource();
      final repository = _createRepository(
        dataSource: dataSource,
        currentUserId: 'account-id',
      );

      final result = await repository.getMyPosts();

      expect(result, isA<Success<List<CommunityPost>>>());
      expect(dataSource.requestedAccountId, 'account-id');
    });

    test('현재 계정 ID를 getLikedPosts 데이터 소스에 전달한다', () async {
      final dataSource = _FakeCommunityPostDataSource();
      final repository = _createRepository(
        dataSource: dataSource,
        currentUserId: 'account-id',
      );

      final result = await repository.getLikedPosts();

      expect(result, isA<Success<List<CommunityPost>>>());
      expect(dataSource.requestedLikedPostsAccountId, 'account-id');
    });

    test('현재 계정 ID를 게시글 변환에 사용한다', () async {
      final dataSource = _FakeCommunityPostDataSource(
        posts: [
          CommunityPostDto(
            id: 'post-id',
            authorId: 'author-id',
            upperRegion: '경상북도',
            lowerRegion: '포항시',
            category: 'free',
            title: '게시글',
            content: '내용',
            createdAt: DateTime.utc(2026, 1, 1).toIso8601String(),
            postLikes: const [
              {'account_id': 'account-id'},
            ],
          ),
        ],
      );
      final repository = _createRepository(
        dataSource: dataSource,
        currentUserId: 'account-id',
      );

      final result = await repository.getPosts(
        upperRegion: '경상북도',
        lowerRegion: '포항시',
      );

      expect(result, isA<Success<List<CommunityPost>>>());
      expect(
        (result as Success<List<CommunityPost>>).data.single.isLiked,
        isTrue,
      );
    });

    test('로그아웃 상태에서는 이미지 업로드를 시작하지 않는다', () async {
      final dataSource = _FakeCommunityPostDataSource();
      final repository = _createRepository(
        dataSource: dataSource,
        currentUserId: null,
      );

      final result = await repository.createPost(
        upperRegion: '경상북도',
        lowerRegion: '포항시',
        category: CommunityCategory.free,
        title: '게시글',
        content: '내용',
        imageFiles: [File('image.jpg')],
      );

      expect(result, isA<Failure<CommunityPost>>());
      expect(dataSource.uploadCallCount, 0);
    });

    test('일부 이미지 업로드 실패 시 먼저 업로드된 이미지를 정리 큐에 등록한다', () async {
      final dataSource = _FakeCommunityPostDataSource(
        uploadResults: [
          const Result.success(
            CommunityUploadedImage(
              storagePath: 'accounts/account-id/first.jpg',
              publicUrl: 'https://example.com/first.jpg',
            ),
          ),
          const Result.failure('두 번째 이미지 업로드 실패'),
        ],
      );
      final storageCleanupRepository = _FakeStorageCleanupRepository();
      final repository = _createRepository(
        dataSource: dataSource,
        storageCleanupRepository: storageCleanupRepository,
        currentUserId: 'account-id',
      );

      final result = await repository.createPost(
        upperRegion: '경상북도',
        lowerRegion: '포항시',
        category: CommunityCategory.free,
        title: '게시글',
        content: '내용',
        imageFiles: [File('first.jpg'), File('second.jpg')],
      );

      expect(result, isA<Failure<CommunityPost>>());
      expect(dataSource.uploadCallCount, 2);
      expect(dataSource.createPostCalled, isFalse);
      expect(storageCleanupRepository.bucketName, 'community-images');
      expect(
        storageCleanupRepository.storagePaths,
        ['accounts/account-id/first.jpg'],
      );
    });
  });
}

CommunityPostRepository _createRepository({
  required _FakeCommunityPostDataSource dataSource,
  required String? currentUserId,
  StorageCleanupRepository? storageCleanupRepository,
}) {
  return CommunityPostRepositoryImpl(
    dataSource: dataSource,
    authRepository: _FakeAuthRepository(currentUserId),
    storageCleanupRepository:
        storageCleanupRepository ?? _FakeStorageCleanupRepository(),
  );
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository(String? currentUserId)
    : _currentUser = currentUserId == null
          ? null
          : User(
              id: currentUserId,
              nickname: '머뭄이',
              authProvider: AuthProvider.google,
            );

  final User? _currentUser;

  @override
  User? get currentUser => _currentUser;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeCommunityPostDataSource implements CommunityPostDataSource {
  _FakeCommunityPostDataSource({
    this.posts = const [],
    List<Result<CommunityUploadedImage>> uploadResults = const [],
  }) : _uploadResults = [...uploadResults];

  final List<CommunityPostDto> posts;
  final List<Result<CommunityUploadedImage>> _uploadResults;
  String? requestedAccountId;
  String? requestedLikedPostsAccountId;
  int uploadCallCount = 0;
  bool createPostCalled = false;

  @override
  Future<Result<List<CommunityPostDto>>> getPosts({
    required String upperRegion,
    required String lowerRegion,
    int limit = 20,
    DateTime? cursor,
  }) async {
    return Result.success(posts);
  }

  @override
  Future<Result<List<CommunityPostDto>>> getMyPosts({
    required String accountId,
    int limit = 20,
    DateTime? cursor,
  }) async {
    requestedAccountId = accountId;
    return Result.success(posts);
  }

  @override
  Future<Result<List<CommunityPostDto>>> getLikedPosts({
    required String accountId,
    int limit = 20,
    DateTime? cursor,
  }) async {
    requestedLikedPostsAccountId = accountId;
    return Result.success(posts);
  }

  @override
  Future<Result<CommunityUploadedImage>> uploadImage({
    required String accountId,
    required File file,
  }) async {
    uploadCallCount++;
    return _uploadResults.removeAt(0);
  }

  @override
  Future<Result<String>> createPost({
    required String upperRegion,
    required String lowerRegion,
    required String category,
    required String title,
    required String content,
    List<CommunityUploadedImage> images = const [],
    CommunityPlace? place,
  }) async {
    createPostCalled = true;
    return const Result.success('post-id');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeStorageCleanupRepository implements StorageCleanupRepository {
  String? bucketName;
  List<String> storagePaths = [];

  @override
  Future<Result<bool>> enqueue({
    required String bucketName,
    required List<String> storagePaths,
  }) async {
    this.bucketName = bucketName;
    this.storagePaths = storagePaths;
    return const Result.success(true);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
