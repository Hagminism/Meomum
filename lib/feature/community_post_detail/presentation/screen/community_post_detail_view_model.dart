import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meomum/core/data/repository/auth/auth_repository_impl.dart';
import 'package:meomum/core/data/repository/community/community_comment_repository_impl.dart';
import 'package:meomum/core/data/repository/community/community_post_repository_impl.dart';
import 'package:meomum/core/domain/repository/auth/auth_repository.dart';
import 'package:meomum/core/domain/repository/community/community_post_repository.dart';
import 'package:meomum/core/domain/repository/community/community_comment_repository.dart';
import 'package:meomum/core/utils/result.dart';
import 'package:meomum/feature/community_post_detail/presentation/screen/community_post_detail_action.dart';
import 'package:meomum/feature/community_post_detail/presentation/screen/community_post_detail_event.dart';
import 'package:meomum/feature/community_post_detail/presentation/screen/community_post_detail_state.dart';

class CommunityPostDetailViewModel extends Notifier<CommunityPostDetailState> {
  final String postId;
  final ImagePicker _imagePicker = ImagePicker();
  late final CommunityPostRepository _repository;
  late final CommunityCommentRepository _commentRepository;
  late final AuthRepository _authRepository;

  CommunityPostDetailViewModel(this.postId);

  final StreamController<CommunityPostDetailEvent> _eventController =
      StreamController<CommunityPostDetailEvent>.broadcast();

  Stream<CommunityPostDetailEvent> get eventStream => _eventController.stream;

  Future<Result<bool>> deletePost() async {
    if (state.isDeleting) {
      return const Result.failure('게시글 삭제가 진행 중입니다.');
    }

    final post = state.post;
    if (post == null) {
      return const Result.failure('게시글을 찾을 수 없습니다.');
    }

    if (!state.isOwner) {
      return const Result.failure('게시글을 삭제할 권한이 없습니다.');
    }

    state = state.copyWith(isDeleting: true);
    late final Result<bool> result;
    try {
      result = await _repository.deletePost(postId: post.id);
    } catch (error) {
      result = Result.failure('게시글 삭제 중 오류가 발생했습니다: $error');
    }

    if (ref.mounted) {
      state = state.copyWith(isDeleting: false);
    }

    return result;
  }

  Future<Result<bool>> deleteComment(String commentId) async {
    final result = await _commentRepository.deleteComment(commentId: commentId);
    if (!ref.mounted) return result;
    switch (result) {
      case Success():
        final post = state.post;
        state = state.copyWith(
          post: post == null
              ? null
              : post.copyWith(
                  commentCount: (post.commentCount - 1).clamp(0, 999999),
                ),
        );
        await _fetchComments();
      case Failure(message: final message):
        _eventController.add(
          CommunityPostDetailEvent.showMessage(message),
        );
    }
    return result;
  }

  void setFocusCommentId(String? commentId) {
    if (state.focusCommentId == commentId) return;
    state = state.copyWith(focusCommentId: commentId);
  }

  @override
  CommunityPostDetailState build() {
    _repository = ref.watch(communityPostRepositoryProvider);
    _commentRepository = ref.watch(communityCommentRepositoryProvider);
    _authRepository = ref.watch(authRepositoryProvider);
    ref.onDispose(() => _eventController.close());
    Future.microtask(_fetchPost);
    return CommunityPostDetailState(
      isLoading: true,
      currentUserId: _authRepository.currentUser?.id,
    );
  }

  void onAction(CommunityPostDetailAction action) {
    if (state.isDeleting) return;

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
      case ReplyToComment(:final commentId):
        final isCancelingReply = state.replyParentId == commentId;
        state = state.copyWith(
          replyParentId: isCancelingReply ? null : commentId,
          commentContent: isCancelingReply ? '' : state.commentContent,
          commentImage: isCancelingReply ? null : state.commentImage,
        );
      case ToggleCommentLike(:final commentId):
        _toggleCommentLike(commentId);
      case EditComment(:final commentId):
        _startEditingComment(commentId);
      case ChangeEditingComment(:final content):
        state = state.copyWith(editingCommentContent: content);
      case SubmitEditingComment():
        _submitEditingComment();
      case CancelEditingComment():
        state = state.copyWith(
          editingCommentId: null,
          editingCommentContent: '',
        );
      case DeleteComment():
      case ReportComment():
        break;
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
        await _fetchComments();
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

  Future<void> _fetchComments() async {
    final result = await _commentRepository.getComments(postId: postId);
    if (!ref.mounted) return;
    switch (result) {
      case Success(data: final comments):
        state = state.copyWith(
          comments: comments,
          isCommentsLoading: false,
        );
      case Failure(message: final message):
        state = state.copyWith(isCommentsLoading: false);
        _eventController.add(CommunityPostDetailEvent.showMessage(message));
    }
  }

  Future<void> _submitComment() async {
    if (!state.isCommentButtonVisible) return;

    state = state.copyWith(isCommentSubmitting: true);
    final result = await _commentRepository.createComment(
      postId: postId,
      parentId: state.replyParentId,
      content: state.commentContent,
      imageFile: state.commentImage == null
          ? null
          : File(state.commentImage!.path),
    );
    if (!ref.mounted) return;
    switch (result) {
      case Success():
        final post = state.post;
        state = state.copyWith(
          post: post == null
              ? null
              : post.copyWith(
                  commentCount: post.commentCount + 1,
                ),
          commentContent: '',
          commentImage: null,
          replyParentId: null,
          isCommentSubmitting: false,
        );
        await _fetchComments();
      case Failure(message: final message):
        state = state.copyWith(isCommentSubmitting: false);
        _eventController.add(CommunityPostDetailEvent.showMessage(message));
    }
  }

  Future<void> _toggleCommentLike(String commentId) async {
    final commentIndex = state.comments.indexWhere(
      (comment) => comment.id == commentId,
    );
    if (commentIndex == -1) return;
    final comment = state.comments[commentIndex];
    final nextLiked = !comment.isLiked;
    state = state.copyWith(
      comments: [
        for (final item in state.comments)
          item.id == commentId
              ? item.copyWith(
                  isLiked: nextLiked,
                  likeCount: nextLiked
                      ? item.likeCount + 1
                      : (item.likeCount - 1).clamp(0, 999999),
                )
              : item,
      ],
    );
    final result = await _commentRepository.toggleLike(commentId: commentId);
    if (!ref.mounted) return;
    if (result case Failure(message: final message)) {
      state = state.copyWith(
        comments: [
          for (final item in state.comments)
            item.id == commentId ? comment : item,
        ],
      );
      _eventController.add(CommunityPostDetailEvent.showMessage(message));
    }
  }

  void _startEditingComment(String commentId) {
    final comment = state.comments.firstWhere(
      (item) => item.id == commentId,
      orElse: () => throw StateError('댓글을 찾을 수 없습니다.'),
    );
    state = state.copyWith(
      editingCommentId: comment.id,
      editingCommentContent: comment.content,
      replyParentId: null,
    );
  }

  Future<void> _submitEditingComment() async {
    final commentId = state.editingCommentId;
    if (commentId == null || state.editingCommentContent.trim().isEmpty) return;
    final comment = state.comments.firstWhere((item) => item.id == commentId);
    final result = await _commentRepository.updateComment(
      commentId: commentId,
      content: state.editingCommentContent,
      storagePath: comment.storagePath,
      imageUrl: comment.imageUrl,
    );
    if (!ref.mounted) return;
    switch (result) {
      case Success():
        state = state.copyWith(
          editingCommentId: null,
          editingCommentContent: '',
        );
        await _fetchComments();
      case Failure(message: final message):
        _eventController.add(CommunityPostDetailEvent.showMessage(message));
    }
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
        break;
      case CommunityPostDetailMenuItem.report:
        break;
    }
  }
}

final communityPostDetailViewModelProvider = NotifierProvider.autoDispose
    .family<CommunityPostDetailViewModel, CommunityPostDetailState, String>(
      CommunityPostDetailViewModel.new,
    );
