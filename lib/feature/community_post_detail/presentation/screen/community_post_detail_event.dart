import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_post_detail_event.freezed.dart';

@freezed
sealed class CommunityPostDetailEvent with _$CommunityPostDetailEvent {
  const factory CommunityPostDetailEvent.showMessage(String message) =
      ShowMessage;
}
