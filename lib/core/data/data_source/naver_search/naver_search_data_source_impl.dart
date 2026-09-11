import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:meomum/core/data/data_source/naver_search/naver_search_data_source.dart';
import 'package:meomum/core/data/dto/naver_search/naver_place_dto.dart';
import 'package:meomum/di/di.dart';

class NaverSearchDataSourceImpl implements NaverSearchDataSource {
  final http.Client _client;

  NaverSearchDataSourceImpl({
    required this._client,
  });

  @override
  Future<NaverSearchResponseDto> searchLocalPlaces({
    required String query,
    int display = 5,
    int start = 1,
  }) async {
    final clientId = dotenv.env['NAVER_SEARCH_CLIENT_ID'] ?? '';
    final clientSecret = dotenv.env['NAVER_SEARCH_CLIENT_SECRET'] ?? '';

    if (clientId.isEmpty || clientSecret.isEmpty) {
      // API 키가 없을 경우 빈 결과 반환
      return const NaverSearchResponseDto();
    }

    final uri = Uri.https(
      'naverapihub.apigw.ntruss.com',
      '/search/v1/local',
      {
        'query': query,
        'display': display.toString(),
        'start': start.toString(),
        'sort': 'random',
        'format': 'json',
      },
    );

    final response = await _client.get(
      uri,
      headers: {
        'X-NCP-APIGW-API-KEY-ID': clientId,
        'X-NCP-APIGW-API-KEY': clientSecret,
      },
    );

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final jsonMap = jsonDecode(decodedBody) as Map<String, dynamic>;
      return NaverSearchResponseDto.fromJson(jsonMap);
    } else {
      throw Exception(
        'Naver Search API Error: ${response.statusCode} - ${response.body}',
      );
    }
  }
}

final naverSearchDataSourceProvider = Provider<NaverSearchDataSource>((
  Ref ref,
) {
  return NaverSearchDataSourceImpl(client: ref.read(httpClientProvider));
});
