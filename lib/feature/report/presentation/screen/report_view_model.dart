import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meomum/core/data/repository/community/community_post_repository_impl.dart';
import 'package:meomum/core/domain/repository/community/community_post_repository.dart';
import 'package:meomum/core/utils/result.dart';
import 'package:meomum/feature/report/presentation/screen/report_action.dart';
import 'package:meomum/feature/report/presentation/screen/report_event.dart';
import 'package:meomum/feature/report/presentation/screen/report_state.dart';

class ReportViewModel extends Notifier<ReportState> {
  final String postId;

  ReportViewModel(this.postId);

  final ImagePicker _imagePicker = ImagePicker();
  late final CommunityPostRepository _repository;

  final StreamController<ReportEvent> _eventController =
      StreamController<ReportEvent>.broadcast();

  Stream<ReportEvent> get eventStream => _eventController.stream;

  @override
  ReportState build() {
    _repository = ref.watch(communityPostRepositoryProvider);
    ref.onDispose(() => _eventController.close());
    Future.microtask(_fetchPost);
    return const ReportState();
  }

  void onAction(ReportAction action) {
    switch (action) {
      case TapBack():
        break;
      case RetryPost():
        _fetchPost();
      case ChangeTitle(:final title):
        state = state.copyWith(title: title);
      case ChangeContent(:final content):
        state = state.copyWith(content: content);
      case PickPhotos():
        _pickPhotos();
      case RemovePhoto(:final index):
        _removePhoto(index);
      case Submit():
        _submitReport();
    }
  }

  /// 게시글 ID로 신고 대상 게시글을 조회합니다.
  Future<void> _fetchPost() async {
    if (state.isFetching) return;

    state = state.copyWith(isFetching: true, loadError: null);

    final result = await _repository.getPostById(postId: postId);

    if (!ref.mounted) return;

    switch (result) {
      case Success(data: final post):
        state = state.copyWith(
          post: post,
          isFetching: false,
          loadError: null,
        );
      case Failure(message: final message):
        state = state.copyWith(
          post: null,
          isFetching: false,
          loadError: message,
        );
    }
  }

  /// 사진 보관함에서 사진을 선택하고 최대 10장까지 상태에 추가합니다.
  Future<void> _pickPhotos() async {
    final remainingCount = 10 - state.mediaFiles.length;
    if (remainingCount <= 0) {
      _eventController.add(
        const ReportEvent.showMessage('사진은 최대 10장까지 추가할 수 있습니다.'),
      );
      return;
    }

    try {
      final pickedFiles = await _imagePicker.pickMultiImage(
        limit: remainingCount,
      );

      if (pickedFiles.isNotEmpty && ref.mounted) {
        final combined = [...state.mediaFiles, ...pickedFiles];
        state = state.copyWith(
          mediaFiles: combined.length > 10 ? combined.sublist(0, 10) : combined,
        );
      }
    } catch (error) {
      _eventController.add(
        ReportEvent.showMessage('사진을 불러오지 못했습니다: $error'),
      );
    }
  }

  /// 선택한 사진을 신고 상태에서 제거합니다.
  void _removePhoto(int index) {
    if (index < 0 || index >= state.mediaFiles.length) return;

    final updatedFiles = List<XFile>.from(state.mediaFiles)..removeAt(index);
    state = state.copyWith(mediaFiles: updatedFiles);
  }

  /// 신고 입력값을 payload로 구성하고 제출 과정을 시뮬레이션합니다.
  Future<void> _submitReport() async {
    if (!state.isSubmitEnabled) return;

    final reportPayload = {
      'postId': postId,
      'title': state.title.trim(),
      'content': state.content.trim(),
      'photos': List<XFile>.unmodifiable(state.mediaFiles),
    };

    state = state.copyWith(isSubmitting: true);
    await _simulateSubmission(reportPayload);

    if (!ref.mounted) return;

    state = state.copyWith(isSubmitting: false);
    _eventController.add(const ReportEvent.submitted());
  }

  /// 실제 전송 연동 전까지 제출 지연을 시뮬레이션합니다.
  Future<void> _simulateSubmission(Map<String, Object> reportPayload) async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));
  }
}

final reportViewModelProvider = NotifierProvider.autoDispose
    .family<ReportViewModel, ReportState, String>(ReportViewModel.new);
