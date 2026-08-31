import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/core/data/repository/community/community_post_repository_impl.dart';
import 'package:meomum/core/domain/repository/community/community_post_repository.dart';
import 'package:meomum/core/utils/result.dart';
import 'package:meomum/feature/community/domain/model/community_post.dart';
import 'package:meomum/feature/community/domain/model/community_region.dart';
import 'package:meomum/feature/community/domain/model/community_regions.dart';
import 'package:meomum/feature/community/presentation/screen/community_action.dart';
import 'package:meomum/feature/community/presentation/screen/community_event.dart';
import 'package:meomum/feature/community/presentation/screen/community_state.dart';

class CommunityViewModel extends Notifier<CommunityState> {
  late final CommunityPostRepository _repository;

  static const int _pageSize = 20;

  @override
  CommunityState build() {
    _repository = ref.watch(communityPostRepositoryProvider);
    ref.onDispose(() => _eventController.close());

    Future.microtask(() => _fetchPosts(CommunityRegions.pohang));

    return const CommunityState(
      selectedRegion: CommunityRegions.pohang,
      posts: [],
      isLoading: true,
    );
  }

  final StreamController<CommunityEvent> _eventController =
      StreamController<CommunityEvent>.broadcast();

  Stream<CommunityEvent> get eventStream => _eventController.stream;

  void onAction(CommunityAction action) {
    switch (action) {
      case TapRegionFilter():
        break;
      case SelectRegion():
        state = state.copyWith(
          selectedRegion: action.region,
          imagePageByPostId: const {},
        );
        _fetchPosts(action.region);
      case SelectCategory():
        state = state.copyWith(
          selectedCategory: action.category,
          imagePageByPostId: const {},
        );
      case ChangeImagePage():
        state = state.copyWith(
          imagePageByPostId: {
            ...state.imagePageByPostId,
            action.postId: action.pageIndex,
          },
        );
      case ToggleLike():
        _toggleLike(action.postId);
      case TapComment():
        _eventController.add(
          const CommunityEvent.showMessage('댓글 기능은 추후 연결 예정입니다.'),
        );
      case TapShare():
        _eventController.add(
          const CommunityEvent.showMessage('공유 기능은 추후 연결 예정입니다.'),
        );
      case TapWrite():
        break;
      case LoadMore():
        _loadMore();
      case Refresh():
        _fetchPosts(state.selectedRegion);
    }
  }

  /// 선택한 지역의 첫 페이지 게시글을 조회하고 상태를 갱신합니다.
  Future<void> _fetchPosts(CommunityRegion region) async {
    state = state.copyWith(isLoading: true);

    final result = await _repository.getPosts(
      upperRegion: region.upperRegion,
      lowerRegion: region.lowerRegion,
      limit: _pageSize,
    );

    switch (result) {
      case Success(data: final posts):
        state = state.copyWith(
          posts: posts,
          isLoading: false,
          hasMore: posts.length >= _pageSize,
        );
      case Failure(message: final message):
        state = state.copyWith(isLoading: false);
        _eventController.add(CommunityEvent.showMessage(message));
    }
  }

  /// 마지막 게시글을 기준으로 다음 페이지를 조회해 목록에 추가합니다.
  Future<void> _loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) {
      return;
    }

    if (state.posts.isEmpty) {
      return;
    }

    state = state.copyWith(isLoadingMore: true);

    final lastPostCreatedAt = state.posts.last.createdAt;

    final result = await _repository.getPosts(
      upperRegion: state.selectedRegion.upperRegion,
      lowerRegion: state.selectedRegion.lowerRegion,
      limit: _pageSize,
      cursor: lastPostCreatedAt,
    );

    switch (result) {
      case Success(data: final newPosts):
        state = state.copyWith(
          posts: [...state.posts, ...newPosts],
          isLoadingMore: false,
          hasMore: newPosts.length >= _pageSize,
        );
      case Failure(message: final message):
        state = state.copyWith(isLoadingMore: false);
        _eventController.add(CommunityEvent.showMessage(message));
    }
  }

  /// 좋아요 상태를 먼저 화면에 반영하고 서버 처리 실패 시 이전 상태로 되돌립니다.
  Future<void> _toggleLike(String postId) async {
    final targetIndex = state.posts.indexWhere((p) => p.id == postId);
    if (targetIndex == -1) return;

    final targetPost = state.posts[targetIndex];
    final currentIsLiked = targetPost.isLiked;

    // Optimistic Update
    final updatedPosts = state.posts
        .map((post) {
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

    final result = await _repository.toggleLike(
      postId: postId,
      isCurrentlyLiked: currentIsLiked,
    );

    if (result case Failure(message: final msg)) {
      // Rollback on failure
      final rollbackPosts = state.posts
          .map((post) {
            if (post.id != postId) return post;
            return post.copyWith(
              isLiked: currentIsLiked,
              likeCount: targetPost.likeCount,
            );
          })
          .toList(growable: false);

      state = state.copyWith(posts: rollbackPosts);
      _eventController.add(CommunityEvent.showMessage(msg));
    }
  }

  /// 현재 선택된 지역과 같은 게시글을 목록의 가장 앞에 추가합니다.
  void addPost(CommunityPost post) {
    // 현재 선택된 지역과 같은 경우 상단에 추가
    if (post.upperRegion == state.selectedRegion.upperRegion &&
        post.lowerRegion == state.selectedRegion.lowerRegion) {
      state = state.copyWith(
        posts: [post, ...state.posts],
      );
    }
  }
}

final communityViewModelProvider =
    NotifierProvider.autoDispose<CommunityViewModel, CommunityState>(
      CommunityViewModel.new,
    );
