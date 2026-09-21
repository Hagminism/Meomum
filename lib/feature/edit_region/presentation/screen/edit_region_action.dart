import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meomum/feature/community/domain/model/community_region.dart';

part 'edit_region_action.freezed.dart';

@freezed
sealed class EditRegionAction with _$EditRegionAction {
  const factory EditRegionAction.tapRegionField() = TapRegionField;

  const factory EditRegionAction.selectRegion(CommunityRegion region) =
      SelectRegion;

  const factory EditRegionAction.tapBack() = TapBack;

  const factory EditRegionAction.tapSubmit() = TapSubmit;
}
