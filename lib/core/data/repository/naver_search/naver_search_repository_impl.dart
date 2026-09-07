import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/core/data/data_source/naver_search/naver_search_data_source.dart';
import 'package:meomum/core/data/data_source/naver_search/naver_search_data_source_impl.dart';
import 'package:meomum/core/domain/repository/naver_search/naver_search_repository.dart';
import 'package:meomum/core/utils/result.dart';
import 'package:meomum/feature/community/domain/model/community_place.dart';

class NaverSearchRepositoryImpl implements NaverSearchRepository {
  final NaverSearchDataSource dataSource;

  NaverSearchRepositoryImpl({
    required this.dataSource,
  });

  @override
  Future<Result<List<CommunityPlace>>> searchPlaces({
    required String query,
    int display = 5,
    int start = 1,
  }) async {
    try {
      final responseDto = await dataSource.searchLocalPlaces(
        query: query,
        display: display,
        start: start,
      );

      final places = responseDto.items
          .map((item) {
            final title = _stripHtmlTags(item.title);
            final category = _stripHtmlTags(item.category);
            final lat = _parseCoordinate(item.mapy);
            final lng = _parseCoordinate(item.mapx);

            return CommunityPlace(
              name: title,
              latitude: lat,
              longitude: lng,
              address: item.address,
              roadAddress: item.roadAddress,
              category: category,
            );
          })
          .toList(growable: false);

      return Result.success(places);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  String _stripHtmlTags(String htmlText) {
    return htmlText
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'");
  }

  double _parseCoordinate(String raw) {
    final val = double.tryParse(raw) ?? 0.0;
    if (val > 1000000) {
      return val / 10000000.0;
    }
    return val;
  }
}

final naverSearchRepositoryProvider = Provider<NaverSearchRepository>((
  Ref ref,
) {
  final dataSource = ref.watch(naverSearchDataSourceProvider);
  return NaverSearchRepositoryImpl(dataSource: dataSource);
});
