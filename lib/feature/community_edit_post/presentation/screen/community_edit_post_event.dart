import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_edit_post_event.freezed.dart';

@freezed
sealed class CommunityEditPostEvent with _$CommunityEditPostEvent {
  const factory CommunityEditPostEvent.postUpdatedSuccess() =
      PostUpdatedSuccess;
  const factory CommunityEditPostEvent.showMessage(String message) =
      ShowMessage;
}
