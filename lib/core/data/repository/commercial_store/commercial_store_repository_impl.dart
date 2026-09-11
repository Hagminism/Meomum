import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/core/data/data_source/commercial_store/commercial_store_data_source.dart';
import 'package:meomum/core/data/data_source/commercial_store/commercial_store_data_source_impl.dart';
import 'package:meomum/core/domain/model/commercial_store/commercial_store.dart';
import 'package:meomum/core/domain/model/location/geo_location.dart';
import 'package:meomum/core/domain/repository/commercial_store/commercial_store_repository.dart';
import 'package:meomum/core/utils/result.dart';

class CommercialStoreRepositoryImpl implements CommercialStoreRepository {
  final CommercialStoreDataSource _dataSource;

  CommercialStoreRepositoryImpl({
    required this._dataSource,
  });

  @override
  Future<Result<List<CommercialStore>>> getNearbyStores({
    required GeoLocation location,
    required int radius,
  }) {
    return _dataSource.getNearbyStores(location: location, radius: radius);
  }
}

final commercialStoreRepositoryProvider = Provider<CommercialStoreRepository>((
  Ref ref,
) {
  return CommercialStoreRepositoryImpl(
    dataSource: ref.watch(commercialStoreDataSourceProvider),
  );
});
