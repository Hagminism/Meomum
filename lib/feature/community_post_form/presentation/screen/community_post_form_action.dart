import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meomum/feature/community/domain/model/community_place.dart';
import 'package:meomum/feature/community/domain/model/community_region.dart';
import 'package:meomum/feature/community/domain/model/enum/community_category.dart';

part 'community_post_form_action.freezed.dart';

@freezed
sealed class CommunityPostFormAction with _$CommunityPostFormAction {
  const factory CommunityPostFormAction.tapRegionSelect() = TapRegionSelect;
  const factory CommunityPostFormAction.tapCategorySelect() = TapCategorySelect;
  const factory CommunityPostFormAction.selectRegion(
    CommunityRegion region,
  ) = SelectRegion;
  const factory CommunityPostFormAction.selectCategory(
    CommunityCategory category,
  ) = SelectCategory;
  const factory CommunityPostFormAction.pickMedia() = PickMedia;
  const factory CommunityPostFormAction.removeMedia(int index) = RemoveMedia;
  const factory CommunityPostFormAction.tapLocationSearch() = TapLocationSearch;
  const factory CommunityPostFormAction.setLocation(CommunityPlace? place) =
      SetLocation;
  const factory CommunityPostFormAction.changeTitle(String title) = ChangeTitle;
  const factory CommunityPostFormAction.changeContent(String content) =
      ChangeContent;
  const factory CommunityPostFormAction.tapUpload() = TapUpload;
  const factory CommunityPostFormAction.tapBack() = TapBack;
}
