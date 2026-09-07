import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meomum/core/data/repository/community/community_post_repository_impl.dart';
import 'package:meomum/core/data/repository/auth/auth_repository_impl.dart';
import 'package:meomum/core/domain/repository/auth/auth_repository.dart';
import 'package:meomum/core/domain/repository/community/community_post_repository.dart';
import 'package:meomum/core/utils/result.dart';
import 'package:meomum/feature/home_post_detail/presentation/screen/home_post_detail_action.dart';
import 'package:meomum/feature/home_post_detail/presentation/screen/home_post_detail_event.dart';
import 'package:meomum/feature/home_post_detail/presentation/screen/home_post_detail_state.dart';

class HomePostDetailViewModel extends Notifier<HomePostDetailState> {
  final String postId;
  final ImagePicker _imagePicker = ImagePicker();
  late final CommunityPostRepository _repository;
  late final AuthRepository _authRepository;

  HomePostDetailViewModel(this.postId);

  final StreamController<HomePostDetailEvent> _eventController =
      StreamController<HomePostDetailEvent>.broadcast();

  Stream<HomePostDetailEvent> get eventStream => _eventController.stream;

  @override
  HomePostDetailState build() {
    _repository = ref.watch(communityPostRepositoryProvider);
    _authRepository = ref.watch(authRepositoryProvider);
    ref.onDispose(() => _eventController.close());
    Future.microtask(_fetchPost);
    return const HomePostDetailState(isLoading: true);
  }

  void onAction(HomePostDetailAction action) {
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
        _eventController.add(HomePostDetailEvent.showMessage(message));
    }
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
      _eventController.add(HomePostDetailEvent.showMessage(message));
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
        HomePostDetailEvent.showMessage('사진을 불러오지 못했습니다: $error'),
      );
    }
  }

  void _submitComment() {
    if (!state.isCommentButtonVisible) return;

    _eventController.add(
      const HomePostDetailEvent.showMessage('댓글 기능은 추후 연결 예정입니다.'),
    );
  }

  void _handleMenu(HomePostDetailMenuItem item) {
    switch (item) {
      case HomePostDetailMenuItem.edit:
        _eventController.add(
          const HomePostDetailEvent.showMessage('게시글 수정 기능은 추후 연결 예정입니다.'),
        );
      case HomePostDetailMenuItem.delete:
        _eventController.add(
          const HomePostDetailEvent.showMessage('게시글 삭제 기능은 추후 연결 예정입니다.'),
        );
      case HomePostDetailMenuItem.report:
        _eventController.add(
          const HomePostDetailEvent.showMessage('신고 기능은 추후 연결 예정입니다.'),
        );
    }
  }
}

final homePostDetailViewModelProvider = NotifierProvider.autoDispose
    .family<HomePostDetailViewModel, HomePostDetailState, String>(
      HomePostDetailViewModel.new,
    );
