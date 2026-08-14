import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/feature/community/data/mock/community_mock_data.dart';
import 'package:meomum/feature/community/domain/model/community_post.dart';
import 'package:meomum/feature/community/presentation/screen/community_action.dart';
import 'package:meomum/feature/community/presentation/screen/community_event.dart';
import 'package:meomum/feature/community/presentation/screen/community_state.dart';

class CommunityViewModel extends Notifier<CommunityState> {
  @override
  CommunityState build() {
    ref.onDispose(() => _eventController.close());

    return const CommunityState(
      selectedRegion: CommunityMockData.pohang,
      posts: CommunityMockData.posts,
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
        _eventController.add(
          const CommunityEvent.showMessage('글쓰기 화면은 추후 연결 예정입니다.'),
        );
    }
  }

  void _toggleLike(String postId) {
    final updatedPosts = state.posts
        .map((CommunityPost post) {
          if (post.id != postId) {
            return post;
          }

          final isLiked = !post.isLiked;

          return post.copyWith(
            isLiked: isLiked,
            likeCount: isLiked ? post.likeCount + 1 : post.likeCount - 1,
          );
        })
        .toList(growable: false);

    state = state.copyWith(posts: updatedPosts);
  }
}

final communityViewModelProvider =
    NotifierProvider.autoDispose<CommunityViewModel, CommunityState>(
      CommunityViewModel.new,
    );
