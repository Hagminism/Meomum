import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meomum/core/data/repository/auth/auth_repository_impl.dart';
import 'package:meomum/core/data/repository/community/community_post_repository_impl.dart';
import 'package:meomum/core/domain/repository/community/community_post_repository.dart';
import 'package:meomum/core/utils/result.dart';
import 'package:meomum/feature/community/domain/model/community_post_image.dart';
import 'package:meomum/feature/community/domain/model/community_region.dart';
import 'package:meomum/feature/community/domain/model/community_regions.dart';
import 'package:meomum/feature/community_post_form/presentation/model/community_post_form_media.dart';
import 'package:meomum/feature/community_post_form/presentation/screen/community_post_form_action.dart';
import 'package:meomum/feature/community_edit_post/presentation/screen/community_edit_post_event.dart';
import 'package:meomum/feature/community_edit_post/presentation/screen/community_edit_post_state.dart';

class CommunityEditPostViewModel extends Notifier<CommunityEditPostState> {
  final String postId;
  final ImagePicker _imagePicker = ImagePicker();
  late final CommunityPostRepository _repository;

  CommunityEditPostViewModel(this.postId);

  final StreamController<CommunityEditPostEvent> _eventController =
      StreamController<CommunityEditPostEvent>.broadcast();

  Stream<CommunityEditPostEvent> get eventStream => _eventController.stream;

  @override
  CommunityEditPostState build() {
    _repository = ref.watch(communityPostRepositoryProvider);
    ref.onDispose(() => _eventController.close());

    final currentUser = ref.read(authRepositoryProvider).currentUser;
    final initialRegion = currentUser?.hasSelectedRegion == true
        ? CommunityRegion(
            upperRegion: currentUser!.upperRegion!,
            lowerRegion: currentUser.lowerRegion!,
          )
        : CommunityRegions.pohang;

    Future.microtask(_fetchPost);

    return CommunityEditPostState(
      postId: postId,
      selectedRegion: initialRegion,
    );
  }

  void onAction(CommunityPostFormAction action) {
    if (state.isLoading) return;

    switch (action) {
      case TapRegionSelect():
        break;
      case TapCategorySelect():
        break;
      case SelectRegion(:final region):
        state = state.copyWith(selectedRegion: region);
      case SelectCategory(:final category):
        state = state.copyWith(category: category);
      case PickMedia():
        _pickMedia();
      case RemoveMedia(:final index):
        _removeMedia(index);
      case TapLocationSearch():
        break;
      case SetLocation(:final place):
        state = state.copyWith(selectedPlace: place);
      case ChangeTitle(:final title):
        state = state.copyWith(title: title);
      case ChangeContent(:final content):
        state = state.copyWith(content: content);
      case TapUpload():
        _updatePost();
      case TapBack():
        break;
    }
  }

  Future<void> _fetchPost() async {
    final result = await _repository.getPostById(postId: postId);

    if (!ref.mounted) return;

    switch (result) {
      case Success(data: final post):
        final currentUserId = ref.read(authRepositoryProvider).currentUser?.id;
        if (post.authorId != currentUserId) {
          state = state.copyWith(
            isInitializing: false,
            errorMessage: '작성자만 게시글을 수정할 수 있습니다.',
          );
          return;
        }

        state = state.copyWith(
          originalPost: post,
          selectedRegion: post.region,
          category: post.category,
          mediaItems: post.images
              .map(
                (CommunityPostImage image) =>
                    CommunityPostFormMedia.remote(image: image),
              )
              .toList(growable: false),
          selectedPlace: post.place,
          title: post.title,
          content: post.content,
          isInitializing: false,
        );
      case Failure(message: final message):
        state = state.copyWith(
          isInitializing: false,
          errorMessage: message,
        );
    }
  }

  Future<void> _pickMedia() async {
    final remainingCount = 10 - state.mediaItems.length;
    if (remainingCount <= 0) {
      _eventController.add(
        const CommunityEditPostEvent.showMessage(
          '사진과 동영상은 최대 10개까지 추가할 수 있습니다.',
        ),
      );
      return;
    }

    try {
      final pickedFiles = await _imagePicker.pickMultipleMedia(
        limit: remainingCount,
      );

      if (!ref.mounted || state.isLoading || pickedFiles.isEmpty) return;

      final combined = [
        ...state.mediaItems,
        ...pickedFiles.map(
          (file) => CommunityPostFormMedia.local(file: file),
        ),
      ];
      state = state.copyWith(
        mediaItems: combined.length > 10 ? combined.sublist(0, 10) : combined,
      );
    } catch (error) {
      _eventController.add(
        CommunityEditPostEvent.showMessage('사진/동영상을 불러오지 못했습니다: $error'),
      );
    }
  }

  void _removeMedia(int index) {
    if (index < 0 || index >= state.mediaItems.length) return;
    final updatedItems = List<CommunityPostFormMedia>.from(state.mediaItems)
      ..removeAt(index);
    state = state.copyWith(mediaItems: updatedItems);
  }

  Future<void> _updatePost() async {
    if (state.isLoading || !state.isUploadEnabled) return;

    state = state.copyWith(isLoading: true);

    final existingImages = state.mediaItems
        .where((CommunityPostFormMedia media) => !media.isLocal)
        .map((CommunityPostFormMedia media) => media.existingImage!)
        .toList(growable: false);
    final newImageFiles = state.mediaItems
        .where((CommunityPostFormMedia media) => media.isLocal)
        .map((CommunityPostFormMedia media) => File(media.localFile!.path))
        .toList(growable: false);

    final result = await _repository.updatePost(
      postId: postId,
      upperRegion: state.selectedRegion.upperRegion,
      lowerRegion: state.selectedRegion.lowerRegion,
      category: state.category,
      title: state.title.trim(),
      content: state.content.trim(),
      existingImages: existingImages,
      newImageFiles: newImageFiles,
      place: state.selectedPlace,
    );

    if (!ref.mounted) return;

    state = state.copyWith(isLoading: false);

    switch (result) {
      case Success():
        _eventController.add(
          const CommunityEditPostEvent.postUpdatedSuccess(),
        );
      case Failure(message: final message):
        _eventController.add(CommunityEditPostEvent.showMessage(message));
    }
  }
}

final communityEditPostViewModelProvider = NotifierProvider.autoDispose
    .family<CommunityEditPostViewModel, CommunityEditPostState, String>(
      CommunityEditPostViewModel.new,
    );
