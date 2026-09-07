import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_post_detail_event.freezed.dart';

@freezed
sealed class HomePostDetailEvent with _$HomePostDetailEvent {
  const factory HomePostDetailEvent.showMessage(String message) = ShowMessage;
}
