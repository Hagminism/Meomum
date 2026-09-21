import 'package:freezed_annotation/freezed_annotation.dart';

part 'edit_region_event.freezed.dart';

@freezed
sealed class EditRegionEvent with _$EditRegionEvent {
  const factory EditRegionEvent.showError(String message) = ShowError;

  const factory EditRegionEvent.regionSaved() = RegionSaved;
}
