import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/core/data/data_source/commercial_store/commercial_store_data_source.dart';
import 'package:meomum/core/domain/model/commercial_store/commercial_store.dart';
import 'package:meomum/core/domain/model/commercial_store/store_industry_catalog.dart';
import 'package:meomum/core/domain/model/location/geo_location.dart';
import 'package:meomum/core/utils/result.dart';
import 'package:meomum/di/di.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommercialStoreDataSourceImpl implements CommercialStoreDataSource {
  static const int _maxRetries = 2;
  static const Duration _baseRetryDelay = Duration(seconds: 1);

  final SupabaseClient _client;

  CommercialStoreDataSourceImpl({
    required this._client,
  });

  @override
  Future<Result<List<CommercialStore>>> getNearbyStores({
    required GeoLocation location,
    required int radius,
  }) async {
    int attempts = 0;

    while (true) {
      try {
        final response = await _client.rpc(
          'get_nearby_stores',
          params: {
            'p_lat': location.latitude,
            'p_lon': location.longitude,
            'p_radius_m': radius,
            'p_inds_lcls_cds': StoreIndustryCatalog.largeCodes,
            'p_inds_mcls_cds': StoreIndustryCatalog.mediumCodes,
            'p_inds_scls_cds': StoreIndustryCatalog.smallCodes,
          },
        );

        final list = response as List<dynamic>;
        final stores = list
            .map(
              (item) => CommercialStore.fromJson(item as Map<String, dynamic>),
            )
            .toList();

        return Result.success(stores);
      } on SocketException catch (error) {
        attempts++;
        if (attempts > _maxRetries) {
          return Result.failure('네트워크 연결을 확인해 주세요. ($error)');
        }
        await Future.delayed(_baseRetryDelay * attempts);
      } on TimeoutException catch (error) {
        attempts++;
        if (attempts > _maxRetries) {
          return Result.failure('요청 시간이 초과되었습니다. ($error)');
        }
        await Future.delayed(_baseRetryDelay * attempts);
      } on PostgrestException catch (error) {
        return Result.failure('데이터베이스 조회에 실패했습니다: ${error.message}');
      } catch (error) {
        return Result.failure('주변 상가를 가져오지 못했습니다. ($error)');
      }
    }
  }
}

final commercialStoreDataSourceProvider = Provider<CommercialStoreDataSource>((
  Ref ref,
) {
  return CommercialStoreDataSourceImpl(
    client: ref.watch(supabaseClientProvider),
  );
});
