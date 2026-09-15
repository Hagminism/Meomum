// The public constructor parameter intentionally initializes a private dependency.
// ignore_for_file: prefer_initializing_formals

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/core/data/data_source/storage_cleanup/storage_cleanup_data_source.dart';
import 'package:meomum/core/utils/result.dart';
import 'package:meomum/di/di.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageCleanupDataSourceImpl implements StorageCleanupDataSource {
  final SupabaseClient _client;

  StorageCleanupDataSourceImpl({required SupabaseClient client})
    : _client = client;

  /// 삭제할 Storage 경로를 서버 정리 큐에 등록해 비동기 재시도를 가능하게 합니다.
  @override
  Future<Result<bool>> enqueue({
    required String bucketName,
    required List<String> storagePaths,
  }) async {
    if (storagePaths.isEmpty) {
      return const Result.success(true);
    }

    try {
      await _client.rpc(
        'enqueue_storage_cleanup',
        params: {
          'p_bucket_id': bucketName,
          'p_storage_paths': storagePaths,
        },
      );
      return const Result.success(true);
    } on PostgrestException catch (error) {
      return Result.failure('Storage 정리 재시도 등록에 실패했습니다: ${error.message}');
    } catch (error) {
      return Result.failure('Storage 정리 재시도 등록 중 오류가 발생했습니다: $error');
    }
  }
}

final storageCleanupDataSourceProvider = Provider<StorageCleanupDataSource>(
  (Ref ref) {
    return StorageCleanupDataSourceImpl(
      client: ref.watch(supabaseClientProvider),
    );
  },
);
