import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/core/data/data_source/tour_info/tour_info_data_source.dart';
import 'package:meomum/core/data/data_source/tour_info/tour_info_data_source_impl.dart';
import 'package:meomum/core/domain/model/location/geo_location.dart';
import 'package:meomum/core/domain/model/tour_spot/tour_spot.dart';
import 'package:meomum/core/domain/repository/tour_info/tour_info_repository.dart';
import 'package:meomum/core/utils/result.dart';

class TourInfoRepositoryImpl implements TourInfoRepository {
  final TourInfoDataSource _dataSource;

  TourInfoRepositoryImpl({
    required this._dataSource,
  });

  @override
  Future<Result<List<TourSpot>>> getNearbyTourSpots({
    required GeoLocation location,
    required int radius,
  }) {
    return _dataSource.getNearbyTourSpots(location: location, radius: radius);
  }
}

final tourInfoRepositoryProvider = Provider<TourInfoRepository>((Ref ref) {
  return TourInfoRepositoryImpl(
    dataSource: ref.watch(tourInfoDataSourceProvider),
  );
});
