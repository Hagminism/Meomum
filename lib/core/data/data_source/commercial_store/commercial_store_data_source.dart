import 'package:meomum/core/domain/model/commercial_store/commercial_store.dart';
import 'package:meomum/core/domain/model/location/geo_location.dart';
import 'package:meomum/core/utils/result.dart';

abstract interface class CommercialStoreDataSource {
  Future<Result<List<CommercialStore>>> getNearbyStores({
    required GeoLocation location,
    required int radius,
  });
}
