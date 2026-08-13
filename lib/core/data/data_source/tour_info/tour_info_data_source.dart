import 'package:meomum/core/domain/model/location/geo_location.dart';
import 'package:meomum/core/domain/model/tour_spot/tour_spot.dart';
import 'package:meomum/core/utils/result.dart';

abstract interface class TourInfoDataSource {
  Future<Result<List<TourSpot>>> getNearbyTourSpots({
    required GeoLocation location,
    required int radius,
  });
}
