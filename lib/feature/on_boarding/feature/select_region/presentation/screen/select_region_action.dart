import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meomum/feature/community/domain/model/community_region.dart';

part 'select_region_action.freezed.dart';

@freezed
sealed class SelectRegionAction with _$SelectRegionAction {
  const factory SelectRegionAction.tapRegionField() = TapRegionField;

  const factory SelectRegionAction.selectRegion(CommunityRegion region) =
      SelectRegion;

  const factory SelectRegionAction.tapBack() = TapBack;

  const factory SelectRegionAction.tapSubmit() = TapSubmit;
}
