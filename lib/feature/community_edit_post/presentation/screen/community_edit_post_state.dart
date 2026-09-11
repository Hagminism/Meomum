import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meomum/feature/community/domain/model/community_place.dart';
import 'package:meomum/feature/community/domain/model/community_post.dart';
import 'package:meomum/feature/community/domain/model/community_region.dart';
import 'package:meomum/feature/community/domain/model/enum/community_category.dart';
import 'package:meomum/feature/community_post_form/presentation/model/community_post_form_media.dart';

part 'community_edit_post_state.freezed.dart';

@freezed
abstract class CommunityEditPostState with _$CommunityEditPostState {
  const CommunityEditPostState._();

  const factory CommunityEditPostState({
    required String postId,
    required CommunityRegion selectedRegion,
    CommunityPost? originalPost,
    @Default(CommunityCategory.free) CommunityCategory category,
    @Default([]) List<CommunityPostFormMedia> mediaItems,
    CommunityPlace? selectedPlace,
    @Default('') String title,
    @Default('') String content,
    @Default(true) bool isInitializing,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _CommunityEditPostState;

  bool get hasChanges {
    final post = originalPost;
    if (post == null) return false;

    final currentImagePaths = mediaItems
        .where((CommunityPostFormMedia media) => !media.isLocal)
        .map((CommunityPostFormMedia media) => media.existingImage!.storagePath)
        .toList(growable: false);
    final originalImagePaths = post.images
        .map((image) => image.storagePath)
        .toList(growable: false);

    return selectedRegion != post.region ||
        category != post.category ||
        selectedPlace != post.place ||
        title.trim() != post.title.trim() ||
        content.trim() != post.content.trim() ||
        !listEquals(currentImagePaths, originalImagePaths) ||
        mediaItems.any((CommunityPostFormMedia media) => media.isLocal);
  }

  bool get isUploadEnabled =>
      !isInitializing &&
      title.trim().isNotEmpty &&
      title.trim().length <= 50 &&
      content.trim().isNotEmpty &&
      content.trim().length <= 10000 &&
      hasChanges &&
      !isLoading;
}
