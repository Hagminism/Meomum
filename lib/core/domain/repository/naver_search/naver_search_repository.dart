import 'package:meomum/core/utils/result.dart';
import 'package:meomum/feature/community/domain/model/community_place.dart';

abstract interface class NaverSearchRepository {
  Future<Result<List<CommunityPlace>>> searchPlaces({
    required String query,
    int display = 5,
    int start = 1,
  });
}
