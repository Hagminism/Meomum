import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meomum/feature/community/domain/model/community_place.dart';
import 'package:meomum/feature/community/domain/model/community_region.dart';
import 'package:meomum/feature/community/domain/model/enum/community_category.dart';

part 'community_write_action.freezed.dart';

@freezed
sealed class CommunityWriteAction with _$CommunityWriteAction {
  const factory CommunityWriteAction.tapRegionSelect() = TapRegionSelect;
  const factory CommunityWriteAction.tapCategorySelect() = TapCategorySelect;
  const factory CommunityWriteAction.selectRegion(
    CommunityRegion region,
  ) = SelectRegion;
  const factory CommunityWriteAction.selectCategory(
    CommunityCategory category,
  ) = SelectCategory;
  const factory CommunityWriteAction.pickMedia() = PickMedia;
  const factory CommunityWriteAction.removeMedia(int index) = RemoveMedia;
  const factory CommunityWriteAction.tapLocationSearch() = TapLocationSearch;
  const factory CommunityWriteAction.setLocation(CommunityPlace? place) =
      SetLocation;
  const factory CommunityWriteAction.changeTitle(String title) = ChangeTitle;
  const factory CommunityWriteAction.changeContent(String content) =
      ChangeContent;
  const factory CommunityWriteAction.tapUpload() = TapUpload;
  const factory CommunityWriteAction.tapBack() = TapBack;
}
