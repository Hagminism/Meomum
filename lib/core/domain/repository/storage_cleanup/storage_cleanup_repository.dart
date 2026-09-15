import 'package:meomum/core/utils/result.dart';

abstract interface class StorageCleanupRepository {
  Future<Result<bool>> enqueue({
    required String bucketName,
    required List<String> storagePaths,
  });
}
