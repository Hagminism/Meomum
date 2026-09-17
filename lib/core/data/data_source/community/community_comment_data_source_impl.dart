// The public constructor parameter intentionally initializes a private dependency.
// ignore_for_file: prefer_initializing_formals

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/core/data/data_source/community/community_comment_data_source.dart';
import 'package:meomum/core/data/data_source/community/community_comment_uploaded_image.dart';
import 'package:meomum/core/data/dto/community/community_comment_dto.dart';
import 'package:meomum/core/utils/result.dart';
import 'package:meomum/di/di.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommunityCommentDataSourceImpl implements CommunityCommentDataSource {
  static const String _bucketName = 'community-images';
  static const String _commentSelect =
      '*, profiles!comments_author_id_fkey('
      'nickname, profile_image_url, upper_region, lower_region), '
      'comment_likes(account_id)';
  static const String _myCommentSelect =
      '*, profiles!comments_author_id_fkey('
      'nickname, profile_image_url, upper_region, lower_region), '
      'posts!comments_post_id_fkey(id, title, category), '
      'comment_likes(account_id)';

  final SupabaseClient _client;

  CommunityCommentDataSourceImpl({required SupabaseClient client})
    : _client = client;

  @override
  Future<Result<List<CommunityCommentDto>>> getComments({
    required String postId,
  }) async {
    try {
      final response = await _client
          .from('comments')
          .select(_commentSelect)
          .eq('post_id', postId)
          .order('created_at', ascending: true);
      final list = response as List<dynamic>;
      return Result.success(
        list
            .map(
              (dynamic item) => CommunityCommentDto.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList(growable: false),
      );
    } on PostgrestException catch (error) {
      return Result.failure('댓글을 불러오지 못했습니다: ${error.message}');
    } catch (error) {
      return Result.failure('댓글을 불러오는 중 오류가 발생했습니다: $error');
    }
  }

  @override
  Future<Result<List<CommunityCommentDto>>> getMyComments({
    required String accountId,
    int limit = 20,
    DateTime? cursor,
  }) async {
    try {
      var query = _client
          .from('comments')
          .select(_myCommentSelect)
          .eq('author_id', accountId)
          .eq('is_deleted', false);
      if (cursor != null) {
        query = query.lt('created_at', cursor.toIso8601String());
      }
      final response = await query
          .order('created_at', ascending: false)
          .limit(limit);
      final list = response as List<dynamic>;
      return Result.success(
        list
            .map(
              (dynamic item) => CommunityCommentDto.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList(growable: false),
      );
    } on PostgrestException catch (error) {
      return Result.failure('내 댓글을 불러오지 못했습니다: ${error.message}');
    } catch (error) {
      return Result.failure('내 댓글을 불러오는 중 오류가 발생했습니다: $error');
    }
  }

  @override
  Future<Result<String>> createComment({
    required String postId,
    String? parentId,
    required String content,
    CommunityCommentUploadedImage? image,
  }) async {
    try {
      final response = await _client.rpc(
        'create_comment',
        params: {
          'p_post_id': postId,
          'p_parent_id': parentId,
          'p_content': content,
          'p_storage_path': image?.storagePath,
          'p_image_url': image?.publicUrl,
        },
      );
      return Result.success(response as String);
    } on PostgrestException catch (error) {
      return Result.failure('댓글 등록에 실패했습니다: ${error.message}');
    } catch (error) {
      return Result.failure('댓글 등록 중 오류가 발생했습니다: $error');
    }
  }

  @override
  Future<Result<bool>> updateComment({
    required String commentId,
    required String content,
    String? storagePath,
    String? imageUrl,
  }) async {
    try {
      final response = await _client.rpc(
        'update_comment',
        params: {
          'p_comment_id': commentId,
          'p_content': content,
          'p_storage_path': storagePath,
          'p_image_url': imageUrl,
        },
      );
      return Result.success(response as bool);
    } on PostgrestException catch (error) {
      return Result.failure('댓글 수정에 실패했습니다: ${error.message}');
    } catch (error) {
      return Result.failure('댓글 수정 중 오류가 발생했습니다: $error');
    }
  }

  @override
  Future<Result<bool>> deleteComment({required String commentId}) async {
    try {
      final response = await _client.rpc(
        'delete_comment',
        params: {'p_comment_id': commentId},
      );
      return Result.success(response as bool);
    } on PostgrestException catch (error) {
      return Result.failure('댓글 삭제에 실패했습니다: ${error.message}');
    } catch (error) {
      return Result.failure('댓글 삭제 중 오류가 발생했습니다: $error');
    }
  }

  @override
  Future<Result<bool>> toggleLike({required String commentId}) async {
    try {
      final response = await _client.rpc(
        'toggle_comment_like',
        params: {'p_comment_id': commentId},
      );
      return Result.success(response as bool);
    } on PostgrestException catch (error) {
      return Result.failure('댓글 좋아요 처리에 실패했습니다: ${error.message}');
    } catch (error) {
      return Result.failure('댓글 좋아요 처리 중 오류가 발생했습니다: $error');
    }
  }

  @override
  Future<Result<CommunityCommentUploadedImage>> uploadImage({
    required String accountId,
    required File file,
  }) async {
    try {
      final timestamp = DateTime.now().microsecondsSinceEpoch;
      final extension = file.path.split('.').last.toLowerCase();
      final storagePath = 'accounts/$accountId/comments/$timestamp.$extension';
      await _client.storage.from(_bucketName).upload(storagePath, file);
      final publicUrl = _client.storage
          .from(_bucketName)
          .getPublicUrl(storagePath);
      return Result.success(
        CommunityCommentUploadedImage(
          storagePath: storagePath,
          publicUrl: publicUrl,
        ),
      );
    } on StorageException catch (error) {
      return Result.failure('댓글 사진 업로드에 실패했습니다: ${error.message}');
    } catch (error) {
      return Result.failure('댓글 사진 업로드 중 오류가 발생했습니다: $error');
    }
  }
}

final communityCommentDataSourceProvider = Provider<CommunityCommentDataSource>(
  (Ref ref) {
    return CommunityCommentDataSourceImpl(
      client: ref.watch(supabaseClientProvider),
    );
  },
);
