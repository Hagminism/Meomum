import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_page_detail_event.freezed.dart';

@freezed
sealed class MyPageDetailEvent with _$MyPageDetailEvent {
  const factory MyPageDetailEvent.showError(String message) = ShowError;
  const factory MyPageDetailEvent.showMessage(String message) = ShowMessage;
}
