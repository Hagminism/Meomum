import 'package:meomum/core/data/dto/naver_search/naver_place_dto.dart';

abstract interface class NaverSearchDataSource {
  Future<NaverSearchResponseDto> searchLocalPlaces({
    required String query,
    int display = 5,
    int start = 1,
  });
}
