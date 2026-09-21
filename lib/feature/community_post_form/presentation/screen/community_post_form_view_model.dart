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
import 'package:meomum/feature/community/domain/model/enum/community_category.dart';
import 'package:meomum/feature/community_post_form/presentation/model/community_post_form_media.dart';
import 'package:meomum/feature/community_post_form/presentation/screen/community_post_form_action.dart';
import 'package:meomum/feature/community_post_form/presentation/screen/community_post_form_event.dart';
import 'package:meomum/feature/community_post_form/presentation/screen/community_post_form_state.dart';

class CommunityPostFormViewModel extends Notifier<CommunityPostFormState> {
  final String? postId;
  final ImagePicker _imagePicker = ImagePicker();
  late final CommunityPostRepository _repository;

  CommunityPostFormViewModel(this.postId);

  final StreamController<CommunityPostFormEvent> _eventController =
      StreamController<CommunityPostFormEvent>.broadcast();

  Stream<CommunityPostFormEvent> get eventStream => _eventController.stream;

  @override
  CommunityPostFormState build() {
    _repository = ref.watch(communityPostRepositoryProvider);
    ref.onDispose(() => _eventController.close());

    final currentUser = ref.read(authRepositoryProvider).currentUser;
    if (postId == null &&
        (currentUser == null || !currentUser.hasSelectedRegion)) {
      throw StateError('거주 지역이 설정된 사용자만 글을 작성할 수 있습니다.');
    }

    final initialRegion = currentUser?.hasSelectedRegion == true
        ? CommunityRegion(
            upperRegion: currentUser!.upperRegion!,
            lowerRegion: currentUser.lowerRegion!,
          )
        : CommunityRegions.pohang;

    if (postId != null) {
      Future.microtask(_fetchPost);
    }

    return CommunityPostFormState(
      postId: postId,
      selectedRegion: initialRegion,
      initialRegion: initialRegion,
      isInitializing: postId != null,
    );
  }

  void onAction(CommunityPostFormAction action) {
    if (state.isLoading || state.isInitializing) return;

    switch (action) {
      case TapRegionSelect():
      case TapCategorySelect():
      case TapLocationSearch():
      case TapRecruitmentDeadline():
      case TapBack():
        break;
      case SelectRegion(:final region):
        state = state.copyWith(selectedRegion: region);
      case SelectCategory(:final category):
        state = state.copyWith(
          category: category,
          wageType: category == CommunityCategory.job ? state.wageType : null,
          wageAmount: category == CommunityCategory.job ? state.wageAmount : '',
          workingTime: category == CommunityCategory.job
              ? state.workingTime
              : '',
          recruitmentDeadline: category == CommunityCategory.job
              ? state.recruitmentDeadline
              : null,
          isAlwaysRecruiting: category == CommunityCategory.job
              ? state.isAlwaysRecruiting
              : false,
        );
      case PickMedia():
        unawaited(_pickMedia());
      case RemoveMedia(:final index):
        _removeMedia(index);
      case SetLocation(:final place):
        state = state.copyWith(selectedPlace: place);
      case ChangeTitle(:final title):
        state = state.copyWith(title: title);
      case ChangeContent(:final content):
        state = state.copyWith(content: content);
      case ChangeWageType(:final wageType):
        state = state.copyWith(
          wageType: wageType,
          wageAmount: wageType == '협의' ? '' : state.wageAmount,
        );
      case ChangeWageAmount(:final amount):
        state = state.copyWith(wageAmount: amount);
      case ChangeWorkingTime(:final workingTime):
        state = state.copyWith(workingTime: workingTime);
      case SelectRecruitmentDeadline(:final deadline):
        state = state.copyWith(recruitmentDeadline: deadline);
      case ToggleAlwaysRecruiting():
        state = state.copyWith(
          isAlwaysRecruiting: !state.isAlwaysRecruiting,
          recruitmentDeadline: state.isAlwaysRecruiting
              ? state.recruitmentDeadline
              : null,
        );
      case TapUpload():
        unawaited(_submitPost());
    }
  }

  Future<void> _fetchPost() async {
    final result = await _repository.getPostById(postId: postId!);

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
          wageType: post.jobWageType,
          wageAmount: post.jobWageAmount?.toStringAsFixed(0) ?? '',
          workingTime: post.jobWorkingTime ?? '',
          recruitmentDeadline: post.jobRecruitmentDeadline,
          isAlwaysRecruiting: post.jobIsAlwaysRecruiting,
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
        const CommunityPostFormEvent.showMessage(
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
        CommunityPostFormEvent.showMessage('사진/동영상을 불러오지 못했습니다: $error'),
      );
    }
  }

  void _removeMedia(int index) {
    if (index < 0 || index >= state.mediaItems.length) return;

    final updatedItems = List<CommunityPostFormMedia>.from(state.mediaItems)
      ..removeAt(index);
    state = state.copyWith(mediaItems: updatedItems);
  }

  Future<void> _submitPost() async {
    if (state.isLoading) return;

    if (!state.isUploadEnabled) {
      _eventController.add(
        CommunityPostFormEvent.showMessage(state.uploadValidationMessage),
      );
      return;
    }

    state = state.copyWith(isLoading: true);

    if (postId == null) {
      final imageFiles = state.mediaItems
          .where((CommunityPostFormMedia media) => media.isLocal)
          .map((CommunityPostFormMedia media) => File(media.localFile!.path))
          .toList(growable: false);
      final result = state.category == CommunityCategory.job
          ? await _repository.createJobPost(
              upperRegion: state.selectedRegion.upperRegion,
              lowerRegion: state.selectedRegion.lowerRegion,
              title: state.title.trim(),
              content: state.content.trim(),
              wageType: state.wageType,
              wageAmount: double.tryParse(state.wageAmount),
              workingTime: state.workingTime.trim().isEmpty
                  ? null
                  : state.workingTime.trim(),
              recruitmentDeadline: state.recruitmentDeadline,
              isAlwaysRecruiting: state.isAlwaysRecruiting,
              imageFiles: imageFiles,
              place: state.selectedPlace,
            )
          : await _repository.createPost(
              upperRegion: state.selectedRegion.upperRegion,
              lowerRegion: state.selectedRegion.lowerRegion,
              category: state.category,
              title: state.title.trim(),
              content: state.content.trim(),
              imageFiles: imageFiles,
              place: state.selectedPlace,
            );

      if (!ref.mounted) return;

      state = state.copyWith(isLoading: false);
      switch (result) {
        case Success(data: final post):
          _eventController.add(CommunityPostFormEvent.postCreated(post));
        case Failure(message: final message):
          _eventController.add(CommunityPostFormEvent.showMessage(message));
      }
      return;
    }

    final existingImages = state.mediaItems
        .where((CommunityPostFormMedia media) => !media.isLocal)
        .map((CommunityPostFormMedia media) => media.existingImage!)
        .toList(growable: false);
    final newImageFiles = state.mediaItems
        .where((CommunityPostFormMedia media) => media.isLocal)
        .map((CommunityPostFormMedia media) => File(media.localFile!.path))
        .toList(growable: false);

    final result = state.category == CommunityCategory.job
        ? await _repository.updateJobPost(
            postId: postId!,
            upperRegion: state.selectedRegion.upperRegion,
            lowerRegion: state.selectedRegion.lowerRegion,
            title: state.title.trim(),
            content: state.content.trim(),
            wageType: state.wageType,
            wageAmount: double.tryParse(state.wageAmount),
            workingTime: state.workingTime.trim().isEmpty
                ? null
                : state.workingTime.trim(),
            recruitmentDeadline: state.recruitmentDeadline,
            isAlwaysRecruiting: state.isAlwaysRecruiting,
            existingImages: existingImages,
            newImageFiles: newImageFiles,
            place: state.selectedPlace,
          )
        : await _repository.updatePost(
            postId: postId!,
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
        _eventController.add(const CommunityPostFormEvent.postUpdated());
      case Failure(message: final message):
        _eventController.add(CommunityPostFormEvent.showMessage(message));
    }
  }
}

final communityPostFormViewModelProvider = NotifierProvider.autoDispose
    .family<CommunityPostFormViewModel, CommunityPostFormState, String?>(
      CommunityPostFormViewModel.new,
    );
