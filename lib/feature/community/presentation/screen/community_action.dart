import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meomum/feature/community/domain/model/enum/community_category.dart';
import 'package:meomum/feature/community/domain/model/community_region.dart';

part 'community_action.freezed.dart';

@freezed
sealed class CommunityAction with _$CommunityAction {
  const factory CommunityAction.tapRegionFilter() = TapRegionFilter;
  const factory CommunityAction.selectRegion(CommunityRegion region) =
      SelectRegion;
  const factory CommunityAction.selectCategory(CommunityCategory category) =
      SelectCategory;
  const factory CommunityAction.changeImagePage(String postId, int pageIndex) =
      ChangeImagePage;
  const factory CommunityAction.toggleLike(String postId) = ToggleLike;
  const factory CommunityAction.tapComment(String postId) = TapComment;
  const factory CommunityAction.tapShare(String postId) = TapShare;
  const factory CommunityAction.tapWrite() = TapWrite;
  const factory CommunityAction.loadMore() = LoadMore;
  const factory CommunityAction.refresh() = Refresh;
}
