import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meomum/core/data/repository/community/community_post_repository_impl.dart';
import 'package:meomum/core/domain/repository/community/community_post_repository.dart';
import 'package:meomum/core/utils/result.dart';
import 'package:meomum/feature/community_write/presentation/screen/community_write_action.dart';
import 'package:meomum/feature/community_write/presentation/screen/community_write_event.dart';
import 'package:meomum/feature/community_write/presentation/screen/community_write_state.dart';

class CommunityWriteViewModel extends Notifier<CommunityWriteState> {
  final ImagePicker _imagePicker = ImagePicker();
  late final CommunityPostRepository _repository;

  @override
  CommunityWriteState build() {
    _repository = ref.watch(communityPostRepositoryProvider);
    ref.onDispose(() => _eventController.close());

    return const CommunityWriteState();
  }

  final StreamController<CommunityWriteEvent> _eventController =
      StreamController<CommunityWriteEvent>.broadcast();

  Stream<CommunityWriteEvent> get eventStream => _eventController.stream;

  void onAction(CommunityWriteAction action) {
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
        _uploadPost();
      case TapBack():
        if (state.isLoading) return;
        _eventController.add(const CommunityWriteEvent.pop());
    }
  }

  /// 사용자가 선택한 미디어를 최대 10개까지 작성 상태에 추가합니다.
  Future<void> _pickMedia() async {
    final remainingCount = 10 - state.mediaFiles.length;
    if (remainingCount <= 0) {
      _eventController.add(
        const CommunityWriteEvent.showMessage('사진과 동영상은 최대 10개까지 추가할 수 있습니다.'),
      );
      return;
    }

    try {
      final pickedFiles = await _imagePicker.pickMultipleMedia(
        limit: remainingCount,
      );

      if (pickedFiles.isNotEmpty) {
        final combined = [...state.mediaFiles, ...pickedFiles];
        final limited = combined.length > 10
            ? combined.sublist(0, 10)
            : combined;
        state = state.copyWith(mediaFiles: limited);
      }
    } catch (e) {
      _eventController.add(
        CommunityWriteEvent.showMessage('사진/동영상을 불러오지 못했습니다: $e'),
      );
    }
  }

  /// 지정한 위치의 미디어를 작성 상태에서 제거합니다.
  void _removeMedia(int index) {
    if (index < 0 || index >= state.mediaFiles.length) return;
    final updatedList = List<XFile>.from(state.mediaFiles)..removeAt(index);
    state = state.copyWith(mediaFiles: updatedList);
  }

  /// 입력값을 검증하고 이미지 업로드와 게시글 등록을 순서대로 처리합니다.
  Future<void> _uploadPost() async {
    if (state.isLoading) return;

    if (!state.isUploadEnabled) {
      _eventController.add(
        const CommunityWriteEvent.showMessage('제목과 내용을 모두 입력해주세요.'),
      );
      return;
    }

    state = state.copyWith(isLoading: true);

    final imageFiles = state.mediaFiles.map((file) => File(file.path)).toList();

    final result = await _repository.createPost(
      upperRegion: state.selectedRegion.upperRegion,
      lowerRegion: state.selectedRegion.lowerRegion,
      category: state.category,
      title: state.title.trim(),
      content: state.content.trim(),
      imageFiles: imageFiles,
      place: state.selectedPlace,
    );

    state = state.copyWith(isLoading: false);

    switch (result) {
      case Success(data: final post):
        _eventController.add(CommunityWriteEvent.postCreatedSuccess(post));
      case Failure(message: final message):
        _eventController.add(CommunityWriteEvent.showMessage(message));
    }
  }
}

final communityWriteViewModelProvider =
    NotifierProvider.autoDispose<CommunityWriteViewModel, CommunityWriteState>(
      CommunityWriteViewModel.new,
    );
