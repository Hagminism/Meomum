import 'package:meomum/core/domain/model/location/geo_location.dart';
import 'package:meomum/core/utils/result.dart';

abstract interface class LocationRepository {
  Future<Result<GeoLocation>> getCurrentLocation();
}
