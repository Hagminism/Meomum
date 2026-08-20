import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meomum/feature/community/data/mock/community_mock_data.dart';
import 'package:meomum/feature/community/domain/model/community_post.dart';
import 'package:meomum/feature/community_write/presentation/screen/community_write_action.dart';
import 'package:meomum/feature/community_write/presentation/screen/community_write_event.dart';
import 'package:meomum/feature/community_write/presentation/screen/community_write_state.dart';

class CommunityWriteViewModel extends Notifier<CommunityWriteState> {
  final ImagePicker _imagePicker = ImagePicker();

  @override
  CommunityWriteState build() {
    ref.onDispose(() => _eventController.close());

    return const CommunityWriteState();
  }

  final StreamController<CommunityWriteEvent> _eventController =
      StreamController<CommunityWriteEvent>.broadcast();

  Stream<CommunityWriteEvent> get eventStream => _eventController.stream;

  void onAction(CommunityWriteAction action) {
    switch (action) {
      case SelectCategory(:final category):
        state = state.copyWith(category: category);
      case PickMedia():
        _pickMedia();
      case RemoveMedia(:final index):
        _removeMedia(index);
      case TapLocationSearch():
        _eventController.add(
          const CommunityWriteEvent.navigateToLocationSearch(),
        );
      case SetLocation(:final place):
        state = state.copyWith(selectedPlace: place);
      case ChangeTitle(:final title):
        state = state.copyWith(title: title);
      case ChangeContent(:final content):
        state = state.copyWith(content: content);
      case TapUpload():
        _uploadPost();
      case TapBack():
        _eventController.add(const CommunityWriteEvent.pop());
    }
  }

  Future<void> _pickMedia() async {
    try {
      final pickedFiles = await _imagePicker.pickMultipleMedia(
        limit: 10 - state.mediaFiles.length,
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

  void _removeMedia(int index) {
    if (index < 0 || index >= state.mediaFiles.length) return;
    final updatedList = List<XFile>.from(state.mediaFiles)..removeAt(index);
    state = state.copyWith(mediaFiles: updatedList);
  }

  Future<void> _uploadPost() async {
    if (!state.isUploadEnabled) {
      _eventController.add(
        const CommunityWriteEvent.showMessage('제목과 내용을 모두 입력해주세요.'),
      );
      return;
    }

    state = state.copyWith(isLoading: true);

    final imageUrls = state.mediaFiles.map((file) => file.path).toList();

    final newPost = CommunityPost(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      region: CommunityMockData.pohang,
      nickname: '나',
      neighborhood: '지곡동',
      timeLabel: '방금 전',
      category: state.category,
      title: state.title.trim(),
      content: state.content.trim(),
      likeCount: 0,
      commentCount: 0,
      isLiked: false,
      isVerified: true,
      imageUrls: imageUrls,
      place: state.selectedPlace,
    );

    state = state.copyWith(isLoading: false);
    _eventController.add(CommunityWriteEvent.postCreatedSuccess(newPost));
  }
}

final communityWriteViewModelProvider =
    NotifierProvider.autoDispose<CommunityWriteViewModel, CommunityWriteState>(
      CommunityWriteViewModel.new,
    );
