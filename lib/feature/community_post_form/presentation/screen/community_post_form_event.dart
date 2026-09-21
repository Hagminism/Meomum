import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meomum/feature/community/domain/model/community_post.dart';

part 'community_post_form_event.freezed.dart';

@freezed
sealed class CommunityPostFormEvent with _$CommunityPostFormEvent {
  const factory CommunityPostFormEvent.postCreated(CommunityPost post) =
      PostCreated;
  const factory CommunityPostFormEvent.postUpdated() = PostUpdated;
  const factory CommunityPostFormEvent.showMessage(String message) =
      ShowMessage;
}
