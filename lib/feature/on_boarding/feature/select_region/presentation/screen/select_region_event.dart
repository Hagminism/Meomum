import 'package:freezed_annotation/freezed_annotation.dart';

part 'select_region_event.freezed.dart';

@freezed
sealed class SelectRegionEvent with _$SelectRegionEvent {
  const factory SelectRegionEvent.showError(String message) = ShowError;

  const factory SelectRegionEvent.regionSaved() = RegionSaved;
}
