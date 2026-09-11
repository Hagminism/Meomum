import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_page_event.freezed.dart';

@freezed
sealed class MyPageEvent with _$MyPageEvent {
  const factory MyPageEvent.showError(String message) = ShowError;
  const factory MyPageEvent.showMessage(String message) = ShowMessage;
}
