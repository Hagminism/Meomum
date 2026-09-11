import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_event.freezed.dart';

@freezed
sealed class CommunityEvent with _$CommunityEvent {
  const factory CommunityEvent.showMessage(String message) = ShowMessage;
}
