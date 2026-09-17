import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/core/data/repository/auth/auth_repository_impl.dart';
import 'package:meomum/core/data/repository/community/community_post_repository_impl.dart';
import 'package:meomum/core/data/repository/community/community_comment_repository_impl.dart';
import 'package:meomum/core/domain/repository/community/community_comment_repository.dart';
import 'package:meomum/core/domain/repository/community/community_post_repository.dart';
import 'package:meomum/core/utils/result.dart';
import 'package:meomum/feature/community/domain/model/community_post.dart';
import 'package:meomum/feature/my_page_detail/domain/model/enum/my_page_feed_tab.dart';
import 'package:meomum/feature/my_page_detail/presentation/screen/my_page_detail_action.dart';
import 'package:meomum/feature/my_page_detail/presentation/screen/my_page_detail_event.dart';
import 'package:meomum/feature/my_page_detail/presentation/screen/my_page_detail_state.dart';

class MyPageDetailViewModel extends Notifier<MyPageDetailState> {
  static const int _pageSize = 20;

  late final CommunityPostRepository _repository;
  late final CommunityCommentRepository _commentRepository;

  @override
  MyPageDetailState build() {
    _repository = ref.watch(communityPostRepositoryProvider);
    _commentRepository = ref.watch(communityCommentRepositoryProvider);
    ref.onDispose(() => _eventController.close());

    final user = ref.read(authRepositoryProvider).currentUser;
    Future.microtask(_fetchMyPosts);

    return MyPageDetailState(
      user: user,
      isLoading: true,
    );
  }

  final StreamController<MyPageDetailEvent> _eventController =
      StreamController<MyPageDetailEvent>.broadcast();

  Stream<MyPageDetailEvent> get eventStream => _eventController.stream;

  void onAction(MyPageDetailAction action) {
    switch (action) {
      case SelectTab(:final tab):
        state = state.copyWith(
          selectedTab: tab,
          imagePageByPostId: const {},
        );
        if (tab == MyPageFeedTab.myPosts && state.posts.isEmpty) {
          _fetchMyPosts();
        }
        if (tab == MyPageFeedTab.myComments && state.comments.isEmpty) {
          _fetchMyComments();
        }
        if (tab == MyPageFeedTab.likedPosts && state.likedPosts.isEmpty) {
          _fetchLikedPosts();
        }
      case ChangeImagePage(:final postId, :final pageIndex):
        state = state.copyWith(
          imagePageByPostId: {
            ...state.imagePageByPostId,
            postId: pageIndex,
          },
        );
      case ToggleLike(:final postId):
        _toggleLike(postId);
      case TapComment():
        break;
      case TapCommentTarget():
        break;
      case TapPost():
      case TapEditProfile():
        break;
      case LoadMore():
        _loadMore();
      case Refresh():
        switch (state.selectedTab) {
          case MyPageFeedTab.myPosts:
            _fetchMyPosts();
          case MyPageFeedTab.myComments:
            _fetchMyComments();
          case MyPageFeedTab.likedPosts:
            _fetchLikedPosts();
        }
      case TapBack():
        break;
    }
  }

  /// 인증 저장소의 최신 사용자 정보를 피드 상태에 반영합니다.
  void refreshUser() {
    state = state.copyWith(
      user: ref.read(authRepositoryProvider).currentUser,
    );
  }

  /// 현재 선택된 탭의 피드를 명시적으로 새로고침합니다.
  Future<void> refresh() {
    return switch (state.selectedTab) {
      MyPageFeedTab.myPosts => _fetchMyPosts(),
      MyPageFeedTab.myComments => _fetchMyComments(),
      MyPageFeedTab.likedPosts => _fetchLikedPosts(),
    };
  }

  /// 내가 작성한 게시글의 첫 페이지를 조회하고 피드 상태를 초기화합니다.
  Future<void> _fetchMyPosts() async {
    state = state.copyWith(
      isLoading: true,
      isLoadingMore: false,
      hasMore: true,
      imagePageByPostId: const {},
    );

    final result = await _repository.getMyPosts(limit: _pageSize);

    if (!ref.mounted) return;

    switch (result) {
      case Success(data: final posts):
        state = state.copyWith(
          posts: posts,
          isLoading: false,
          hasMore: posts.length >= _pageSize,
        );
      case Failure(message: final message):
        state = state.copyWith(isLoading: false);
        _eventController.add(MyPageDetailEvent.showError(message));
    }
  }

  /// 마지막으로 조회한 게시글을 기준으로 다음 페이지를 조회합니다.
  Future<void> _loadMore() async {
    if (state.selectedTab == MyPageFeedTab.myComments) {
      await _loadMoreComments();
      return;
    }
    if (state.selectedTab == MyPageFeedTab.likedPosts) {
      await _loadMoreLikedPosts();
      return;
    }
    if (state.isLoading ||
        state.isLoadingMore ||
        !state.hasMore ||
        state.posts.isEmpty) {
      return;
    }

    state = state.copyWith(isLoadingMore: true);
    final result = await _repository.getMyPosts(
      limit: _pageSize,
      cursor: state.posts.last.createdAt,
    );

    if (!ref.mounted) return;

    switch (result) {
      case Success(data: final newPosts):
        state = state.copyWith(
          posts: [...state.posts, ...newPosts],
          isLoadingMore: false,
          hasMore: newPosts.length >= _pageSize,
        );
      case Failure(message: final message):
        state = state.copyWith(isLoadingMore: false);
        _eventController.add(MyPageDetailEvent.showError(message));
    }
  }

  Future<void> _fetchMyComments() async {
    state = state.copyWith(
      isLoading: true,
      isCommentsLoading: true,
      isLoadingMore: false,
      hasMoreComments: true,
    );
    final result = await _commentRepository.getMyComments(limit: _pageSize);
    if (!ref.mounted) return;
    switch (result) {
      case Success(data: final comments):
        state = state.copyWith(
          comments: comments,
          isLoading: false,
          isCommentsLoading: false,
          hasMoreComments: comments.length >= _pageSize,
        );
      case Failure(message: final message):
        state = state.copyWith(isLoading: false, isCommentsLoading: false);
        _eventController.add(MyPageDetailEvent.showError(message));
    }
  }

  Future<void> _loadMoreComments() async {
    if (state.isLoading ||
        state.isLoadingMore ||
        !state.hasMoreComments ||
        state.comments.isEmpty) {
      return;
    }
    state = state.copyWith(isLoadingMore: true);
    final result = await _commentRepository.getMyComments(
      limit: _pageSize,
      cursor: state.comments.last.createdAt,
    );
    if (!ref.mounted) return;
    switch (result) {
      case Success(data: final comments):
        state = state.copyWith(
          comments: [...state.comments, ...comments],
          isLoadingMore: false,
          hasMoreComments: comments.length >= _pageSize,
        );
      case Failure(message: final message):
        state = state.copyWith(isLoadingMore: false);
        _eventController.add(MyPageDetailEvent.showError(message));
    }
  }

  /// 좋아요한 게시글의 첫 페이지를 조회하고 피드 상태를 초기화합니다.
  Future<void> _fetchLikedPosts() async {
    state = state.copyWith(
      isLoading: true,
      isLikedPostsLoading: true,
      isLoadingMore: false,
      hasMoreLikedPosts: true,
      imagePageByPostId: const {},
    );

    final result = await _repository.getLikedPosts(limit: _pageSize);

    if (!ref.mounted) return;

    switch (result) {
      case Success(data: final posts):
        state = state.copyWith(
          likedPosts: posts,
          isLoading: false,
          isLikedPostsLoading: false,
          hasMoreLikedPosts: posts.length >= _pageSize,
        );
      case Failure(message: final message):
        state = state.copyWith(
          isLoading: false,
          isLikedPostsLoading: false,
        );
        _eventController.add(MyPageDetailEvent.showError(message));
    }
  }

  /// 마지막으로 조회한 좋아요 게시글을 기준으로 다음 페이지를 조회합니다.
  Future<void> _loadMoreLikedPosts() async {
    if (state.isLoading ||
        state.isLoadingMore ||
        !state.hasMoreLikedPosts ||
        state.likedPosts.isEmpty) {
      return;
    }

    state = state.copyWith(isLoadingMore: true);
    final result = await _repository.getLikedPosts(
      limit: _pageSize,
      cursor: state.likedPosts.last.createdAt,
    );

    if (!ref.mounted) return;

    switch (result) {
      case Success(data: final newPosts):
        state = state.copyWith(
          likedPosts: [...state.likedPosts, ...newPosts],
          isLoadingMore: false,
          hasMoreLikedPosts: newPosts.length >= _pageSize,
        );
      case Failure(message: final message):
        state = state.copyWith(isLoadingMore: false);
        _eventController.add(MyPageDetailEvent.showError(message));
    }
  }

  /// 게시글의 좋아요 상태를 먼저 변경하고 저장소 결과에 따라 롤백합니다.
  Future<void> _toggleLike(String postId) async {
    final isLikedPostsTab = state.selectedTab == MyPageFeedTab.likedPosts;
    final currentPosts = isLikedPostsTab ? state.likedPosts : state.posts;
    final targetIndex = currentPosts.indexWhere((CommunityPost post) {
      return post.id == postId;
    });
    if (targetIndex == -1) return;

    final targetPost = currentPosts[targetIndex];
    final currentIsLiked = targetPost.isLiked;
    final nextIsLiked = !currentIsLiked;
    final updatedPosts = currentPosts
        .map((CommunityPost post) {
          if (post.id != postId) return post;
          return post.copyWith(
            isLiked: nextIsLiked,
            likeCount: nextIsLiked
                ? post.likeCount + 1
                : (post.likeCount - 1).clamp(0, 999999),
          );
        })
        .where((CommunityPost post) => !isLikedPostsTab || post.isLiked)
        .toList(growable: false);

    state = isLikedPostsTab
        ? state.copyWith(likedPosts: updatedPosts)
        : state.copyWith(posts: updatedPosts);
    final result = await _repository.toggleLike(postId: postId);

    if (!ref.mounted) return;

    if (result case Failure(message: final message)) {
      if (isLikedPostsTab) {
        state = state.copyWith(likedPosts: currentPosts);
      } else {
        final rollbackPosts = state.posts
            .map((CommunityPost post) {
              if (post.id != postId) return post;
              return post.copyWith(
                isLiked: currentIsLiked,
                likeCount: targetPost.likeCount,
              );
            })
            .toList(growable: false);

        state = state.copyWith(posts: rollbackPosts);
      }
      _eventController.add(MyPageDetailEvent.showError(message));
    }
  }
}

final myPageDetailViewModelProvider =
    NotifierProvider.autoDispose<MyPageDetailViewModel, MyPageDetailState>(
      MyPageDetailViewModel.new,
    );
