import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meomum/core/data/repository/auth/auth_repository_impl.dart';
import 'package:meomum/core/data/repository/community/community_post_repository_impl.dart';
import 'package:meomum/core/domain/repository/auth/auth_repository.dart';
import 'package:meomum/core/domain/repository/community/community_post_repository.dart';
import 'package:meomum/core/utils/result.dart';
import 'package:meomum/feature/community_post_detail/presentation/screen/community_post_detail_action.dart';
import 'package:meomum/feature/community_post_detail/presentation/screen/community_post_detail_event.dart';
import 'package:meomum/feature/community_post_detail/presentation/screen/community_post_detail_state.dart';

class CommunityPostDetailViewModel extends Notifier<CommunityPostDetailState> {
  final String postId;
  final ImagePicker _imagePicker = ImagePicker();
  late final CommunityPostRepository _repository;
  late final AuthRepository _authRepository;

  CommunityPostDetailViewModel(this.postId);

  final StreamController<CommunityPostDetailEvent> _eventController =
      StreamController<CommunityPostDetailEvent>.broadcast();

  Stream<CommunityPostDetailEvent> get eventStream => _eventController.stream;

  @override
  CommunityPostDetailState build() {
    _repository = ref.watch(communityPostRepositoryProvider);
    _authRepository = ref.watch(authRepositoryProvider);
    ref.onDispose(() => _eventController.close());
    Future.microtask(_fetchPost);
    return const CommunityPostDetailState(isLoading: true);
  }

  void onAction(CommunityPostDetailAction action) {
    switch (action) {
      case TapBack():
        break;
      case ToggleLike():
        _toggleLike();
      case ChangeComment(:final content):
        state = state.copyWith(commentContent: content);
      case PickImage():
        _pickImage();
      case SubmitComment():
        _submitComment();
      case TapMenu(:final item):
        _handleMenu(item);
    }
  }

  Future<void> _fetchPost() async {
    final result = await _repository.getPostById(postId: postId);

    if (!ref.mounted) return;

    switch (result) {
      case Success(data: final post):
        state = state.copyWith(
          post: post,
          isLoading: false,
          isOwner: post.authorId == _authRepository.currentUser?.id,
        );
      case Failure(message: final message):
        state = state.copyWith(isLoading: false);
        _eventController.add(CommunityPostDetailEvent.showMessage(message));
    }
  }

  Future<void> refresh() async {
    if (!ref.mounted) return;

    state = state.copyWith(isLoading: true);
    await _fetchPost();
  }

  Future<void> _toggleLike() async {
    final post = state.post;
    if (post == null) return;

    final wasLiked = post.isLiked;
    state = state.copyWith(
      post: post.copyWith(
        isLiked: !wasLiked,
        likeCount: !wasLiked
            ? post.likeCount + 1
            : (post.likeCount - 1).clamp(0, 999999),
      ),
    );

    final result = await _repository.toggleLike(
      postId: post.id,
    );

    if (!ref.mounted) return;

    if (result case Failure(message: final message)) {
      state = state.copyWith(post: post);
      _eventController.add(CommunityPostDetailEvent.showMessage(message));
    }
  }

  Future<void> _pickImage() async {
    try {
      final image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null && ref.mounted) {
        state = state.copyWith(commentImage: image);
      }
    } catch (error) {
      _eventController.add(
        CommunityPostDetailEvent.showMessage('사진을 불러오지 못했습니다: $error'),
      );
    }
  }

  void _submitComment() {
    if (!state.isCommentButtonVisible) return;

    _eventController.add(
      const CommunityPostDetailEvent.showMessage('댓글 기능은 추후 연결 예정입니다.'),
    );
  }

  void _handleMenu(CommunityPostDetailMenuItem item) {
    switch (item) {
      case CommunityPostDetailMenuItem.edit:
        _eventController.add(
          const CommunityPostDetailEvent.showMessage(
            '게시글 수정 기능은 추후 연결 예정입니다.',
          ),
        );
      case CommunityPostDetailMenuItem.delete:
        _eventController.add(
          const CommunityPostDetailEvent.showMessage(
            '게시글 삭제 기능은 추후 연결 예정입니다.',
          ),
        );
      case CommunityPostDetailMenuItem.report:
        break;
    }
  }
}

final communityPostDetailViewModelProvider = NotifierProvider.autoDispose
    .family<CommunityPostDetailViewModel, CommunityPostDetailState, String>(
      CommunityPostDetailViewModel.new,
    );
