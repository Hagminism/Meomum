import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meomum/core/data/data_source/location/location_data_source.dart';
import 'package:meomum/core/domain/model/location/geo_location.dart';
import 'package:meomum/core/utils/result.dart';
import 'package:meomum/di/di.dart';

class LocationDataSourceImpl implements LocationDataSource {
  final GeolocatorPlatform _geolocator;

  LocationDataSourceImpl({
    required this._geolocator,
  });

  @override
  Future<Result<GeoLocation>> getCurrentLocation() async {
    final serviceEnabled = await _geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const Result.failure('위치 서비스가 비활성화되어 있습니다.');
    }

    var permission = await _geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return const Result.failure('위치 권한이 허용되지 않았습니다.');
    }

    try {
      final position = await _geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      return Result.success(
        GeoLocation(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );
    } catch (e) {
      return Result.failure('현재 위치를 가져오지 못했습니다. ($e)');
    }
  }
}

final locationDataSourceProvider = Provider<LocationDataSource>((Ref ref) {
  return LocationDataSourceImpl(
    geolocator: ref.watch(geolocatorProvider),
  );
});
