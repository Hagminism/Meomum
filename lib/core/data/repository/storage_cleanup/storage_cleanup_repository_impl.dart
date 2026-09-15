// The public constructor parameter intentionally initializes a private dependency.
// ignore_for_file: prefer_initializing_formals

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/core/data/data_source/storage_cleanup/storage_cleanup_data_source.dart';
import 'package:meomum/core/data/data_source/storage_cleanup/storage_cleanup_data_source_impl.dart';
import 'package:meomum/core/domain/repository/storage_cleanup/storage_cleanup_repository.dart';
import 'package:meomum/core/utils/result.dart';

class StorageCleanupRepositoryImpl implements StorageCleanupRepository {
  final StorageCleanupDataSource _dataSource;

  StorageCleanupRepositoryImpl({required StorageCleanupDataSource dataSource})
    : _dataSource = dataSource;

  /// Storage 정리 요청을 데이터 소스에 위임해 서버 재시도 큐에 등록합니다.
  @override
  Future<Result<bool>> enqueue({
    required String bucketName,
    required List<String> storagePaths,
  }) {
    return _dataSource.enqueue(
      bucketName: bucketName,
      storagePaths: storagePaths,
    );
  }
}

final storageCleanupRepositoryProvider = Provider<StorageCleanupRepository>(
  (Ref ref) {
    return StorageCleanupRepositoryImpl(
      dataSource: ref.watch(storageCleanupDataSourceProvider),
    );
  },
);
