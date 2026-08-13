import 'package:freezed_annotation/freezed_annotation.dart';

part 'map_event.freezed.dart';

@freezed
sealed class MapEvent with _$MapEvent {
  const factory MapEvent.showMessage(String message) = ShowMessage;
  const factory MapEvent.showError(String message) = ShowError;
}
