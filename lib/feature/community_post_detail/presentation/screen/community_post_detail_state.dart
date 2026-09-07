import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meomum/feature/community/domain/model/community_post.dart';

part 'community_post_detail_state.freezed.dart';

@freezed
abstract class CommunityPostDetailState with _$CommunityPostDetailState {
  const CommunityPostDetailState._();

  const factory CommunityPostDetailState({
    CommunityPost? post,
    @Default(false) bool isLoading,
    @Default(false) bool isOwner,
    @Default('') String commentContent,
    XFile? commentImage,
  }) = _CommunityPostDetailState;

  bool get isCommentButtonVisible => commentContent.trim().isNotEmpty;
}
