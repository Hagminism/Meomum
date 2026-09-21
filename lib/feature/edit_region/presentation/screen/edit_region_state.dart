import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meomum/feature/community/domain/model/community_region.dart';

part 'edit_region_state.freezed.dart';

@freezed
abstract class EditRegionState with _$EditRegionState {
  const EditRegionState._();

  const factory EditRegionState({
    CommunityRegion? selectedRegion,
    @Default(false) bool isLoading,
  }) = _EditRegionState;

  bool get isValid => selectedRegion != null;
}
