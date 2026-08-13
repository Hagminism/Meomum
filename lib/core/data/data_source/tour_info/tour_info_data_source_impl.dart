import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:meomum/core/data/data_source/tour_info/tour_info_data_source.dart';
import 'package:meomum/core/data/dto/tour_spot/tour_spot_dto.dart';
import 'package:meomum/core/data/mapper/tour_spot/tour_spot_mapper.dart';
import 'package:meomum/core/domain/model/location/geo_location.dart';
import 'package:meomum/core/domain/model/tour_spot/tour_spot.dart';
import 'package:meomum/core/utils/result.dart';
import 'package:meomum/di/di.dart';

class TourInfoDataSourceImpl implements TourInfoDataSource {
  final http.Client _client;
  final String _serviceKey;

  TourInfoDataSourceImpl({
    required this._client,
    required this._serviceKey,
  });

  static const String _endpoint =
      'https://apis.data.go.kr/B551011/KorService2/locationBasedList2';
  static const String _mobileOS = 'ETC';
  static const String _mobileApp = 'Meomum';
  static const int _maxRadiusMeter = 20000;
  static const int _numOfRows = 50;

  @override
  Future<Result<List<TourSpot>>> getNearbyTourSpots({
    required GeoLocation location,
    required int radius,
  }) async {
    final uri = Uri.parse(_endpoint).replace(
      queryParameters: {
        'serviceKey': _serviceKey,
        'MobileOS': _mobileOS,
        'MobileApp': _mobileApp,
        '_type': 'json',
        'arrange': 'E', // 거리순 정렬
        'numOfRows': '$_numOfRows',
        'pageNo': '1',
        'mapX': '${location.longitude}',
        'mapY': '${location.latitude}',
        'radius': '${radius.clamp(1, _maxRadiusMeter)}',
      },
    );

    try {
      final response = await _client.get(uri);

      if (response.statusCode != 200) {
        return Result.failure('주변 관광정보 조회에 실패했습니다. (HTTP ${response.statusCode})');
      }

      final json =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

      final header = _extractHeader(json);
      final resultCode = header?['resultCode'] as String?;

      if (resultCode != '0000') {
        final message = header?['resultMsg'] as String? ?? '알 수 없는 오류';
        return Result.failure('주변 관광정보 조회에 실패했습니다. ($message)');
      }

      final tourSpots = _extractItems(json)
          .map((item) => TourSpotDto.fromJson(item).toModel())
          .whereType<TourSpot>()
          .toList();

      return Result.success(tourSpots);
    } catch (e) {
      return Result.failure('주변 관광정보를 가져오지 못했습니다. ($e)');
    }
  }

  Map<String, dynamic>? _extractHeader(Map<String, dynamic> json) {
    final responseMap = json['response'] as Map<String, dynamic>?;
    return responseMap?['header'] as Map<String, dynamic>?;
  }

  // TourAPI는 결과가 1건일 때 item을 배열이 아닌 단일 객체로 내려주므로 방어적으로 파싱한다.
  List<Map<String, dynamic>> _extractItems(Map<String, dynamic> json) {
    final responseMap = json['response'] as Map<String, dynamic>?;
    final body = responseMap?['body'] as Map<String, dynamic>?;
    final items = body?['items'];

    if (items is! Map<String, dynamic>) {
      return const [];
    }

    final item = items['item'];

    if (item is List) {
      return item.cast<Map<String, dynamic>>();
    }
    if (item is Map<String, dynamic>) {
      return [item];
    }

    return const [];
  }
}

final tourInfoDataSourceProvider = Provider<TourInfoDataSource>((Ref ref) {
  return TourInfoDataSourceImpl(
    client: ref.watch(httpClientProvider),
    serviceKey: ref.watch(tourApiServiceKeyProvider),
  );
});
