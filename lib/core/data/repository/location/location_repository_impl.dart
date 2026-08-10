import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/core/data/data_source/location/location_data_source.dart';
import 'package:meomum/core/data/data_source/location/location_data_source_impl.dart';
import 'package:meomum/core/domain/model/location/geo_location.dart';
import 'package:meomum/core/domain/repository/location/location_repository.dart';
import 'package:meomum/core/utils/result.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationDataSource _dataSource;

  LocationRepositoryImpl({
    required this._dataSource,
  });

  @override
  Future<Result<GeoLocation>> getCurrentLocation() {
    return _dataSource.getCurrentLocation();
  }
}

final locationRepositoryProvider = Provider<LocationRepository>((Ref ref) {
  return LocationRepositoryImpl(
    dataSource: ref.watch(locationDataSourceProvider),
  );
});
