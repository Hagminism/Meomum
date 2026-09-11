import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/core/data/repository/auth/auth_repository_impl.dart';
import 'package:meomum/core/data/data_source/community/community_post_data_source.dart';
import 'package:meomum/core/data/dto/community/community_post_dto.dart';
import 'package:meomum/core/data/model/community/community_image_cleanup_item.dart';
import 'package:meomum/core/data/model/community/community_post_update_result.dart';
import 'package:meomum/core/domain/repository/auth/auth_repository.dart';
import 'package:meomum/core/utils/result.dart';
import 'package:meomum/di/di.dart';
import 'package:meomum/feature/community/domain/model/community_place.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 커뮤니티 게시글과 관련된 Supabase 데이터 접근을 담당합니다.
/// 게시글 조회·작성, 이미지 Storage 처리, 좋아요 처리를 수행합니다.
class CommunityPostDataSourceImpl implements CommunityPostDataSource {
  /// 커뮤니티 이미지가 저장되는 Storage 버킷 이름을 정의합니다.
  static const String _bucketName = 'community-images';

  /// 게시글 목록과 상세 조회에서 함께 가져올 관계 데이터를 정의합니다.
  static const String _postSelect =
      '*, profiles!posts_author_id_fkey('
      'nickname, profile_image_url, upper_region, lower_region), '
      'post_images(storage_path, public_url, sort_order), '
      'post_likes(account_id)';

  /// 이미지가 하나 이상 연결된 게시글만 조회하기 위한 관계 선택문을 정의합니다.
  static const String _postSelectWithImages =
      '*, profiles!posts_author_id_fkey('
      'nickname, profile_image_url, upper_region, lower_region), '
      'post_images!inner(storage_path, public_url, sort_order), '
      'post_likes(account_id)';

  final SupabaseClient _client;
  final AuthRepository _authRepository;

  CommunityPostDataSourceImpl({
    required this._client,
    required this._authRepository,
  });

  @override
  /// 현재 로그인한 사용자의 내부 `accounts.id`를 반환합니다.
  String? get currentUserId => _authRepository.currentUser?.id;

  @override
  /// 지역과 커서 기준으로 게시글 목록을 조회합니다.
  /// 커서가 있으면 마지막으로 조회한 게시글보다 오래된 게시글만 조회합니다.
  Future<Result<List<CommunityPostDto>>> getPosts({
    required String upperRegion,
    required String lowerRegion,
    int limit = 20,
    DateTime? cursor,
  }) async {
    try {
      // 작성자 프로필, 이미지, 좋아요 정보를 게시글과 함께 조회합니다.
      var query = _client
          .from('posts')
          .select(_postSelect)
          .eq('upper_region', upperRegion)
          .eq('lower_region', lowerRegion);

      if (cursor != null) {
        // 생성일을 커서로 사용해 다음 페이지의 게시글을 조회합니다.
        query = query.lt('created_at', cursor.toIso8601String());
      }

      // 최신 게시글부터 페이지 크기만큼 조회합니다.
      final response = await query
          .order('created_at', ascending: false)
          .limit(limit);

      final list = response as List<dynamic>;
      final posts = list
          .map(
            (item) => CommunityPostDto.fromJson(item as Map<String, dynamic>),
          )
          .toList();

      return Result.success(posts);
    } on PostgrestException catch (error) {
      return Result.failure('게시글을 불러오지 못했습니다: ${error.message}');
    } catch (error) {
      return Result.failure('오류가 발생했습니다: $error');
    }
  }

  @override
  /// 현재 로그인한 사용자가 작성한 게시글을 조회합니다.
  /// 커서가 있으면 마지막으로 조회한 게시글보다 오래된 게시글만 조회합니다.
  Future<Result<List<CommunityPostDto>>> getMyPosts({
    int limit = 20,
    DateTime? cursor,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return const Result.failure('로그인이 필요합니다.');
      }

      var query = _client
          .from('posts')
          .select(_postSelect)
          .eq('author_id', userId);

      if (cursor != null) {
        query = query.lt('created_at', cursor.toIso8601String());
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(limit);

      final list = response as List<dynamic>;
      final posts = list
          .map(
            (item) => CommunityPostDto.fromJson(item as Map<String, dynamic>),
          )
          .toList();

      return Result.success(posts);
    } on PostgrestException catch (error) {
      return Result.failure('게시글을 불러오지 못했습니다: ${error.message}');
    } catch (error) {
      return Result.failure('오류가 발생했습니다: $error');
    }
  }

  @override
  /// 지역 조건 없이 이미지가 있는 최신 게시글 목록을 조회합니다.
  /// 커서가 있으면 마지막으로 조회한 게시글보다 오래된 게시글만 조회합니다.
  Future<Result<List<CommunityPostDto>>> getLatestPostsWithImages({
    int limit = 20,
    DateTime? cursor,
  }) async {
    try {
      var query = _client.from('posts').select(_postSelectWithImages);

      if (cursor != null) {
        // 생성일을 커서로 사용해 다음 페이지의 게시글을 조회합니다.
        query = query.lt('created_at', cursor.toIso8601String());
      }

      // 지역과 관계없이 이미지가 있는 최신 게시글부터 조회합니다.
      final response = await query
          .order('created_at', ascending: false)
          .limit(limit);

      final list = response as List<dynamic>;
      final posts = list
          .map(
            (item) => CommunityPostDto.fromJson(item as Map<String, dynamic>),
          )
          .toList();

      return Result.success(posts);
    } on PostgrestException catch (error) {
      return Result.failure('게시글을 불러오지 못했습니다: ${error.message}');
    } catch (error) {
      return Result.failure('오류가 발생했습니다: $error');
    }
  }

  @override
  /// 게시글 ID로 게시글 상세 정보와 관계 데이터를 조회합니다.
  Future<Result<CommunityPostDto>> getPostById({
    required String postId,
  }) async {
    try {
      final response = await _client
          .from('posts')
          .select(_postSelect)
          .eq('id', postId)
          .single();

      return Result.success(CommunityPostDto.fromJson(response));
    } on PostgrestException catch (error) {
      return Result.failure('게시글을 불러오지 못했습니다: ${error.message}');
    } catch (error) {
      return Result.failure('오류가 발생했습니다: $error');
    }
  }

  @override
  /// 이미지 메타데이터와 게시글 정보를 DB RPC로 함께 저장합니다.
  /// 작성자 ID는 클라이언트 값이 아니라 현재 인증 계정으로 서버에서 결정합니다.
  Future<Result<String>> createPost({
    required String upperRegion,
    required String lowerRegion,
    required String category,
    required String title,
    required String content,
    List<CommunityUploadedImage> images = const [],
    CommunityPlace? place,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return const Result.failure('로그인이 필요합니다.');
      }

      // Storage에 먼저 업로드된 이미지의 경로와 URL을 RPC에 전달합니다.
      final postId =
          await _client.rpc(
                'create_post_with_images',
                params: {
                  'p_upper_region': upperRegion,
                  'p_lower_region': lowerRegion,
                  'p_category': category,
                  'p_title': title,
                  'p_content': content,
                  'p_images': images
                      .asMap()
                      .entries
                      .map(
                        (entry) => {
                          'storage_path': entry.value.storagePath,
                          'public_url': entry.value.publicUrl,
                          'sort_order': entry.key,
                        },
                      )
                      .toList(growable: false),
                  'p_place_name': place?.name,
                  'p_place_latitude': place?.latitude,
                  'p_place_longitude': place?.longitude,
                  'p_place_address': place?.address,
                  'p_place_road_address': place?.roadAddress,
                  'p_place_category': place?.category,
                },
              )
              as String;

      return Result.success(postId);
    } on PostgrestException catch (error) {
      return Result.failure('게시글 등록에 실패했습니다: ${error.message}');
    } catch (error) {
      return Result.failure('오류가 발생했습니다: $error');
    }
  }

  @override
  /// 게시글과 이미지 메타데이터를 수정 RPC로 원자적으로 갱신합니다.
  Future<Result<CommunityPostUpdateResult>> updatePost({
    required String postId,
    required String upperRegion,
    required String lowerRegion,
    required String category,
    required String title,
    required String content,
    List<CommunityUploadedImage> images = const [],
    CommunityPlace? place,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return const Result.failure('로그인이 필요합니다.');
      }

      // Repository가 구성한 최종 이미지 목록을 게시글·이미지 메타데이터와 함께 원자적으로 수정합니다.
      final response = await _client.rpc(
        'update_post_with_images',
        params: {
          'p_post_id': postId,
          'p_upper_region': upperRegion,
          'p_lower_region': lowerRegion,
          'p_category': category,
          'p_title': title,
          'p_content': content,
          'p_images': images
              .asMap()
              .entries
              .map(
                (entry) => {
                  'storage_path': entry.value.storagePath,
                  'public_url': entry.value.publicUrl,
                  'sort_order': entry.key,
                },
              )
              .toList(growable: false),
          'p_place_name': place?.name,
          'p_place_latitude': place?.latitude,
          'p_place_longitude': place?.longitude,
          'p_place_address': place?.address,
          'p_place_road_address': place?.roadAddress,
          'p_place_category': place?.category,
        },
      );
      final responseMap = response as Map<String, dynamic>;
      // RPC가 반환한 삭제 대상은 DB 반영 이후 Storage에서 별도로 정리합니다.
      final removedPaths =
          (responseMap['removed_storage_paths'] as List<dynamic>? ??
                  const <dynamic>[])
              .whereType<String>()
              .toList(growable: false);

      return Result.success(
        CommunityPostUpdateResult(
          postId: responseMap['post_id'] as String,
          removedStoragePaths: removedPaths,
        ),
      );
    } on PostgrestException catch (error) {
      return Result.failure('게시글 수정에 실패했습니다: ${error.message}');
    } catch (error) {
      return Result.failure('게시글 수정 중 오류가 발생했습니다: $error');
    }
  }

  @override
  /// 선택한 이미지 파일을 현재 계정 전용 Storage 경로에 업로드합니다.
  /// 일부 파일 업로드 또는 이후 게시글 저장이 실패하면 이미 업로드된 파일을 정리합니다.
  Future<Result<List<CommunityUploadedImage>>> uploadImages({
    required List<File> files,
  }) async {
    final uploadedImages = <CommunityUploadedImage>[];

    try {
      final userId = currentUserId;
      if (userId == null) {
        return const Result.failure('로그인이 필요합니다.');
      }

      final timestamp = DateTime.now().microsecondsSinceEpoch;

      for (int i = 0; i < files.length; i++) {
        // 계정별 경로를 사용해 Storage 정책이 소유권을 검증할 수 있도록 합니다.
        final file = files[i];
        final fileExtension = file.path.split('.').last;
        final storagePath = 'accounts/$userId/${timestamp}_$i.$fileExtension';

        // 파일마다 고유한 계정 전용 경로를 사용해 부분 업로드도 추적할 수 있게 합니다.
        await _client.storage.from(_bucketName).upload(storagePath, file);

        // 업로드가 완료된 파일의 공개 URL을 생성해 게시글 메타데이터에 사용합니다.
        final publicUrl = _client.storage
            .from(_bucketName)
            .getPublicUrl(storagePath);
        uploadedImages.add(
          CommunityUploadedImage(
            storagePath: storagePath,
            publicUrl: publicUrl,
          ),
        );
      }

      return Result.success(uploadedImages);
    } on StorageException catch (error) {
      final cleanupMessage = await _cleanupUploadedImages(uploadedImages);
      return Result.failure(
        '이미지 업로드에 실패했습니다: ${error.message}$cleanupMessage',
      );
    } catch (error) {
      final cleanupMessage = await _cleanupUploadedImages(uploadedImages);
      return Result.failure(
        '이미지 업로드 중 오류가 발생했습니다: $error$cleanupMessage',
      );
    }
  }

  /// 게시글 저장에 실패했을 때 이미 업로드된 Storage 파일을 삭제합니다.
  Future<String> _cleanupUploadedImages(
    List<CommunityUploadedImage> uploadedImages,
  ) async {
    if (uploadedImages.isEmpty) {
      return '';
    }

    // 업로드 중간 실패 시 완료된 파일부터 삭제하고, 삭제 실패분은 큐 등록으로 넘깁니다.
    final result = await deleteImages(
      storagePaths: uploadedImages
          .map((CommunityUploadedImage image) => image.storagePath)
          .toList(growable: false),
    );

    return switch (result) {
      Success() => '',
      Failure(message: final message) => await _enqueueCleanupAndReturnMessage(
        uploadedImages: uploadedImages,
        message: message,
      ),
    };
  }

  Future<String> _enqueueCleanupAndReturnMessage({
    required List<CommunityUploadedImage> uploadedImages,
    required String message,
  }) async {
    // 동일 경로는 큐 테이블의 unique 제약으로 중복 등록되지 않습니다.
    final enqueueResult = await enqueueImageCleanup(
      storagePaths: uploadedImages
          .map((CommunityUploadedImage image) => image.storagePath)
          .toList(growable: false),
    );

    return switch (enqueueResult) {
      Success() => ' 업로드한 이미지 정리에 실패했습니다. 다음 실행 시 재시도합니다: $message',
      Failure(message: final enqueueMessage) =>
        ' 업로드한 이미지 정리와 재시도 등록에 실패했습니다: $message ($enqueueMessage)',
    };
  }

  @override
  /// 지정한 Storage 경로의 이미지 파일을 삭제합니다.
  Future<Result<bool>> deleteImages({
    required List<String> storagePaths,
  }) async {
    if (storagePaths.isEmpty) {
      return const Result.success(true);
    }

    try {
      await _client.storage.from(_bucketName).remove(storagePaths);
      return const Result.success(true);
    } on StorageException catch (error) {
      return Result.failure('업로드한 이미지 정리에 실패했습니다: ${error.message}');
    } catch (error) {
      return Result.failure('업로드한 이미지 정리 중 오류가 발생했습니다: $error');
    }
  }

  @override
  Future<Result<List<CommunityImageCleanupItem>>>
  getPendingImageCleanup() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return const Result.success([]);
      }

      final response = await _client
          .from('community_image_cleanup_queue')
          .select('storage_path')
          .eq('account_id', userId)
          .lte('next_retry_at', DateTime.now().toUtc().toIso8601String())
          .order('next_retry_at')
          .limit(20);
      // 만료된 항목만 최대 20개씩 가져와 앱 재개 시 요청량을 제한합니다.
      final list = response as List<dynamic>;

      return Result.success(
        list
            .map(
              (item) => CommunityImageCleanupItem(
                storagePath:
                    (item as Map<String, dynamic>)['storage_path'] as String,
              ),
            )
            .toList(growable: false),
      );
    } on PostgrestException catch (error) {
      return Result.failure('이미지 정리 대상을 불러오지 못했습니다: ${error.message}');
    } catch (error) {
      return Result.failure('이미지 정리 대상을 불러오는 중 오류가 발생했습니다: $error');
    }
  }

  @override
  Future<Result<bool>> enqueueImageCleanup({
    required List<String> storagePaths,
  }) async {
    if (storagePaths.isEmpty) {
      return const Result.success(true);
    }

    // RPC가 현재 계정 소유 경로인지 검증한 뒤 큐에 등록합니다.
    try {
      await _client.rpc(
        'enqueue_community_image_cleanup',
        params: {
          'p_storage_paths': storagePaths,
        },
      );
      return const Result.success(true);
    } on PostgrestException catch (error) {
      return Result.failure('이미지 정리 재시도 등록에 실패했습니다: ${error.message}');
    } catch (error) {
      return Result.failure('이미지 정리 재시도 등록 중 오류가 발생했습니다: $error');
    }
  }

  @override
  Future<Result<bool>> completeImageCleanup({
    required List<String> storagePaths,
  }) async {
    if (storagePaths.isEmpty) {
      return const Result.success(true);
    }

    // 실제 삭제에 성공한 경로만 큐에서 제거해 실패 항목은 보존합니다.
    try {
      final userId = currentUserId;
      if (userId == null) {
        return const Result.failure('로그인이 필요합니다.');
      }

      await _client
          .from('community_image_cleanup_queue')
          .delete()
          .eq('account_id', userId)
          .inFilter('storage_path', storagePaths);
      return const Result.success(true);
    } on PostgrestException catch (error) {
      return Result.failure('이미지 정리 완료 처리에 실패했습니다: ${error.message}');
    } catch (error) {
      return Result.failure('이미지 정리 완료 처리 중 오류가 발생했습니다: $error');
    }
  }

  @override
  Future<Result<bool>> recordImageCleanupFailure({
    required List<String> storagePaths,
    required String message,
  }) async {
    if (storagePaths.isEmpty) {
      return const Result.success(true);
    }

    // 재시도 간격과 실패 횟수는 DB RPC에서 계산해 모든 호출 경로에 동일하게 적용합니다.
    try {
      await _client.rpc(
        'record_community_image_cleanup_failure',
        params: {
          'p_storage_paths': storagePaths,
          'p_message': message,
        },
      );
      return const Result.success(true);
    } on PostgrestException catch (error) {
      return Result.failure('이미지 정리 실패 기록에 실패했습니다: ${error.message}');
    } catch (error) {
      return Result.failure('이미지 정리 실패 기록 중 오류가 발생했습니다: $error');
    }
  }

  @override
  /// 현재 사용자의 좋아요 상태를 변경하고 게시글의 좋아요 수를 갱신합니다.
  /// 좋아요 행과 게시글의 집계 값을 RPC에서 원자적으로 처리합니다.
  Future<Result<bool>> toggleLike({
    required String postId,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return const Result.failure('로그인이 필요합니다.');
      }

      // 기존 좋아요 행을 확인해 삭제하거나 추가한 뒤 게시글의 좋아요 수를 갱신합니다.
      final response = await _client.rpc(
        'toggle_post_like',
        params: {'p_post_id': postId},
      );
      return Result.success(response as bool);
    } on PostgrestException catch (error) {
      return Result.failure('좋아요 처리에 실패했습니다: ${error.message}');
    } catch (error) {
      return Result.failure('오류가 발생했습니다: $error');
    }
  }
}

/// 커뮤니티 게시글 데이터 소스를 의존성 주입 컨테이너에 등록합니다.
final communityPostDataSourceProvider = Provider<CommunityPostDataSource>((
  Ref ref,
) {
  return CommunityPostDataSourceImpl(
    client: ref.watch(supabaseClientProvider),
    authRepository: ref.watch(authRepositoryProvider),
  );
});
