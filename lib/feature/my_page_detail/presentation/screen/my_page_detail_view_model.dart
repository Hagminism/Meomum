import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/core/data/repository/auth/auth_repository_impl.dart';
import 'package:meomum/core/data/repository/community/community_post_repository_impl.dart';
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

  @override
  MyPageDetailState build() {
    _repository = ref.watch(communityPostRepositoryProvider);
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
        _eventController.add(
          const MyPageDetailEvent.showMessage('댓글 기능은 추후 연결 예정입니다.'),
        );
      case TapPost():
      case TapEditProfile():
        break;
      case LoadMore():
        _loadMore();
      case Refresh():
        if (state.selectedTab == MyPageFeedTab.myPosts) {
          _fetchMyPosts();
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
    if (state.selectedTab != MyPageFeedTab.myPosts) {
      return Future<void>.value();
    }

    return _fetchMyPosts();
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
    if (state.selectedTab != MyPageFeedTab.myPosts ||
        state.isLoading ||
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

  /// 게시글의 좋아요 상태를 먼저 변경하고 저장소 결과에 따라 롤백합니다.
  Future<void> _toggleLike(String postId) async {
    final targetIndex = state.posts.indexWhere((CommunityPost post) {
      return post.id == postId;
    });
    if (targetIndex == -1) return;

    final targetPost = state.posts[targetIndex];
    final currentIsLiked = targetPost.isLiked;
    final updatedPosts = state.posts
        .map((CommunityPost post) {
          if (post.id != postId) return post;
          final nextIsLiked = !currentIsLiked;
          return post.copyWith(
            isLiked: nextIsLiked,
            likeCount: nextIsLiked
                ? post.likeCount + 1
                : (post.likeCount - 1).clamp(0, 999999),
          );
        })
        .toList(growable: false);

    state = state.copyWith(posts: updatedPosts);
    final result = await _repository.toggleLike(postId: postId);

    if (!ref.mounted) return;

    if (result case Failure(message: final message)) {
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
      _eventController.add(MyPageDetailEvent.showError(message));
    }
  }
}

final myPageDetailViewModelProvider =
    NotifierProvider.autoDispose<MyPageDetailViewModel, MyPageDetailState>(
      MyPageDetailViewModel.new,
    );
