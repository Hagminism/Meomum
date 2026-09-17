import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meomum/feature/community/domain/model/community_comment.dart';
import 'package:meomum/feature/community/domain/model/community_post.dart';

part 'community_post_detail_state.freezed.dart';

@freezed
abstract class CommunityPostDetailState with _$CommunityPostDetailState {
  const CommunityPostDetailState._();

  const factory CommunityPostDetailState({
    CommunityPost? post,
    String? currentUserId,
    @Default(false) bool isLoading,
    @Default(false) bool isDeleting,
    @Default(false) bool isOwner,
    @Default([]) List<CommunityComment> comments,
    @Default(false) bool isCommentsLoading,
    @Default(false) bool isCommentSubmitting,
    String? replyParentId,
    String? editingCommentId,
    @Default('') String editingCommentContent,
    @Default(false) bool isEditingCommentSubmitting,
    String? focusCommentId,
    @Default('') String commentContent,
    XFile? commentImage,
  }) = _CommunityPostDetailState;

  bool get isCommentButtonVisible =>
      commentContent.trim().isNotEmpty && !isCommentSubmitting;

  bool get isCommentEditing => editingCommentId != null;
}
