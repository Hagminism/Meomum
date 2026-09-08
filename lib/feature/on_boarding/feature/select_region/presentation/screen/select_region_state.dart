import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meomum/feature/community/domain/model/community_region.dart';

part 'select_region_state.freezed.dart';

@freezed
abstract class SelectRegionState with _$SelectRegionState {
  const SelectRegionState._();

  const factory SelectRegionState({
    CommunityRegion? selectedRegion,
    @Default(false) bool isLoading,
  }) = _SelectRegionState;

  bool get isValid => selectedRegion != null;
}
