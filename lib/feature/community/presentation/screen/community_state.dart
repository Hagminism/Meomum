import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meomum/feature/community/domain/model/enum/community_category.dart';
import 'package:meomum/feature/community/domain/model/community_post.dart';
import 'package:meomum/feature/community/domain/model/community_region.dart';

part 'community_state.freezed.dart';

@freezed
abstract class CommunityState with _$CommunityState {
  const CommunityState._();

  const factory CommunityState({
    required CommunityRegion selectedRegion,
    @Default(CommunityCategory.free) CommunityCategory selectedCategory,
    @Default([]) List<CommunityPost> posts,
    @Default({}) Map<String, int> imagePageByPostId,
  }) = _CommunityState;

  List<CommunityPost> get visiblePosts {
    return posts
        .where(
          (CommunityPost post) =>
              post.region.upperRegion == selectedRegion.upperRegion &&
              post.region.lowerRegion == selectedRegion.lowerRegion &&
              post.category == selectedCategory,
        )
        .toList(growable: false);
  }
}
