import 'package:meomum/core/utils/result.dart';
import 'package:meomum/feature/community/domain/model/tour_api_job_posting.dart';

abstract interface class TourApiJobPostingRepository {
  Future<Result<List<TourApiJobPosting>>> getJobPostings({
    required String upperRegion,
    required String lowerRegion,
    int limit = 20,
  });

  Future<Result<TourApiJobPosting>> getJobPostingById({
    required String empmnInfoNo,
  });

  Future<Result<Map<String, dynamic>>> getDetail({
    required String empmnInfoNo,
  });
}
