import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meomum/feature/community/domain/model/community_post.dart';

part 'community_write_event.freezed.dart';

@freezed
sealed class CommunityWriteEvent with _$CommunityWriteEvent {
  const factory CommunityWriteEvent.navigateToLocationSearch() =
      NavigateToLocationSearch;
  const factory CommunityWriteEvent.postCreatedSuccess(CommunityPost post) =
      PostCreatedSuccess;
  const factory CommunityWriteEvent.showMessage(String message) = ShowMessage;
  const factory CommunityWriteEvent.pop() = Pop;
}
