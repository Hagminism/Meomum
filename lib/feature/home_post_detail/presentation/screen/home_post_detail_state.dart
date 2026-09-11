import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meomum/feature/community/domain/model/community_post.dart';

part 'home_post_detail_state.freezed.dart';

@freezed
abstract class HomePostDetailState with _$HomePostDetailState {
  const HomePostDetailState._();

  const factory HomePostDetailState({
    CommunityPost? post,
    @Default(false) bool isLoading,
    @Default(false) bool isOwner,
    @Default('') String commentContent,
    XFile? commentImage,
  }) = _HomePostDetailState;

  bool get isCommentButtonVisible => commentContent.trim().isNotEmpty;
}
