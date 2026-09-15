import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/core/data/data_source/community/community_post_data_source.dart';
import 'package:meomum/core/data/dto/community/community_post_dto.dart';
import 'package:meomum/core/data/model/community/community_post_update_result.dart';
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

  CommunityPostDataSourceImpl({
    required this._client,
  });

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
    required String accountId,
    int limit = 20,
    DateTime? cursor,
  }) async {
    try {
      var query = _client
          .from('posts')
          .select(_postSelect)
          .eq('author_id', accountId);

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
  /// 게시글을 삭제하고 Storage 이미지 정리 대상 경로를 반환합니다.
  Future<Result<List<String>>> deletePost({
    required String postId,
  }) async {
    try {
      final response = await _client.rpc(
        'delete_post_with_images',
        params: {'p_post_id': postId},
      );
      final responseMap = response as Map<String, dynamic>;
      final storagePaths =
          (responseMap['storage_paths'] as List<dynamic>? ?? const <dynamic>[])
              .whereType<String>()
              .toList(growable: false);

      return Result.success(storagePaths);
    } on PostgrestException catch (error) {
      return Result.failure('게시글 삭제에 실패했습니다: ${error.message}');
    } catch (error) {
      return Result.failure('게시글 삭제 중 오류가 발생했습니다: $error');
    }
  }

  /// 계정 전용 경로에 이미지 한 장을 업로드하고 Storage 메타데이터를 반환합니다.
  /// 여러 파일의 업로드 순서와 실패한 파일 정리는 Repository가 담당합니다.
  @override
  Future<Result<CommunityUploadedImage>> uploadImage({
    required String accountId,
    required File file,
  }) async {
    try {
      final timestamp = DateTime.now().microsecondsSinceEpoch;
      final fileExtension = file.path.split('.').last;
      final storagePath = 'accounts/$accountId/$timestamp.$fileExtension';

      await _client.storage.from(_bucketName).upload(storagePath, file);

      final publicUrl = _client.storage
          .from(_bucketName)
          .getPublicUrl(storagePath);
      return Result.success(
        CommunityUploadedImage(
          storagePath: storagePath,
          publicUrl: publicUrl,
        ),
      );
    } on StorageException catch (error) {
      return Result.failure('이미지 업로드에 실패했습니다: ${error.message}');
    } catch (error) {
      return Result.failure('이미지 업로드 중 오류가 발생했습니다: $error');
    }
  }

  @override
  /// 현재 사용자의 좋아요 상태를 변경하고 게시글의 좋아요 수를 갱신합니다.
  /// 좋아요 행과 게시글의 집계 값을 RPC에서 원자적으로 처리합니다.
  Future<Result<bool>> toggleLike({
    required String postId,
  }) async {
    try {
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
  );
});
