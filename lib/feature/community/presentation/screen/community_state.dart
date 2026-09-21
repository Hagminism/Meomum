import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meomum/feature/community/domain/model/enum/community_category.dart';
import 'package:meomum/feature/community/domain/model/community_post.dart';
import 'package:meomum/feature/community/domain/model/community_region.dart';
import 'package:meomum/feature/community/domain/model/tour_api_job_posting.dart';

part 'community_state.freezed.dart';

@freezed
abstract class CommunityState with _$CommunityState {
  const CommunityState._();

  const factory CommunityState({
    required CommunityRegion selectedRegion,
    @Default(CommunityCategory.free) CommunityCategory selectedCategory,
    @Default([]) List<CommunityPost> posts,
    @Default([]) List<TourApiJobPosting> tourApiJobPostings,
    @Default({}) Map<String, int> imagePageByPostId,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMore,
    @Default(true) bool hasMore,
    @Default(false) bool isTourApiLoading,
    String? tourApiErrorMessage,
  }) = _CommunityState;

  List<CommunityPost> get visiblePosts {
    return posts
        .where(
          (CommunityPost post) => post.category == selectedCategory,
        )
        .toList(growable: false);
  }

  List<CommunityPost> get visibleJobPosts {
    return posts
        .where(
          (CommunityPost post) => post.category == CommunityCategory.job,
        )
        .toList(growable: false);
  }
}
