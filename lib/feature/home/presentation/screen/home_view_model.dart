import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/core/data/repository/community/community_post_repository_impl.dart';
import 'package:meomum/core/domain/model/category/category.dart';
import 'package:meomum/core/domain/repository/community/community_post_repository.dart';
import 'package:meomum/core/utils/result.dart';
import 'package:meomum/feature/community/domain/model/community_post.dart';
import 'package:meomum/feature/community/domain/model/enum/community_category.dart';
import 'package:meomum/feature/home/domain/model/home_banner.dart';
import 'package:meomum/feature/home/domain/model/home_feed_item.dart';
import 'package:meomum/feature/home/presentation/screen/home_action.dart';
import 'package:meomum/feature/home/presentation/screen/home_event.dart';
import 'package:meomum/feature/home/presentation/screen/home_state.dart';

class HomeViewModel extends Notifier<HomeState> {
  late final CommunityPostRepository _repository;

  static const int _pageSize = 20;
  DateTime? _cursor;

  @override
  HomeState build() {
    _repository = ref.watch(communityPostRepositoryProvider);
    ref.onDispose(() => _eventController.close());
    Future.microtask(_fetchInitialPosts);

    return HomeState(
      banners: _mockBanners,
      categories: _categories,
      isLoading: true,
    );
  }

  final StreamController<HomeEvent> _eventController =
      StreamController<HomeEvent>.broadcast();

  Stream<HomeEvent> get eventStream => _eventController.stream;

  void onAction(HomeAction action) {
    switch (action) {
      case ChangeBannerIndex(:final index):
        state = state.copyWith(currentBannerIndex: index);
      case TapCategory():
        break;
      case TapFeedItem():
        break;
      case LoadMore():
        _loadMore();
    }
  }

  Future<void> refresh() async {
    if (state.isLoading || state.isRefreshing || state.isLoadingMore) {
      return;
    }

    await _fetchInitialPosts(preserveFeedItems: true);
  }

  Future<void> _fetchInitialPosts({bool preserveFeedItems = false}) async {
    final previousCursor = _cursor;
    final previousHasMore = state.hasMore;
    _cursor = null;
    state = state.copyWith(
      feedItems: preserveFeedItems ? state.feedItems : const [],
      isLoading: !preserveFeedItems,
      isRefreshing: preserveFeedItems,
      isLoadingMore: false,
      hasMore: preserveFeedItems ? state.hasMore : true,
    );

    final result = await _repository.getLatestPostsWithImages(
      limit: _pageSize,
    );

    if (!ref.mounted) {
      return;
    }

    switch (result) {
      case Success(data: final posts):
        _cursor = posts.isEmpty ? null : posts.last.createdAt;
        state = state.copyWith(
          feedItems: posts.map(_toHomeFeedItem).toList(growable: false),
          isLoading: false,
          isRefreshing: false,
          hasMore: posts.length >= _pageSize,
        );
      case Failure(message: final message):
        if (preserveFeedItems) {
          _cursor = previousCursor;
        }

        state = state.copyWith(
          isLoading: false,
          isRefreshing: false,
          hasMore: preserveFeedItems ? previousHasMore : state.hasMore,
        );
        _eventController.add(HomeEvent.showMessage(message));
    }
  }

  Future<void> _loadMore() async {
    if (state.isLoading ||
        state.isRefreshing ||
        state.isLoadingMore ||
        !state.hasMore) {
      return;
    }

    if (state.feedItems.isEmpty || _cursor == null) {
      return;
    }

    state = state.copyWith(isLoadingMore: true);

    final result = await _repository.getLatestPostsWithImages(
      limit: _pageSize,
      cursor: _cursor,
    );

    if (!ref.mounted) {
      return;
    }

    switch (result) {
      case Success(data: final posts):
        if (posts.isNotEmpty) {
          _cursor = posts.last.createdAt;
        }

        state = state.copyWith(
          feedItems: [
            ...state.feedItems,
            ...posts.map(_toHomeFeedItem),
          ],
          isLoadingMore: false,
          hasMore: posts.length >= _pageSize,
        );
      case Failure(message: final message):
        state = state.copyWith(isLoadingMore: false);
        _eventController.add(HomeEvent.showMessage(message));
    }
  }

  HomeFeedItem _toHomeFeedItem(CommunityPost post) {
    return HomeFeedItem(
      id: post.id,
      category: post.category.label,
      title: post.title,
      content: post.content,
      likeCount: post.likeCount,
      commentCount: post.commentCount,
      timeLabel: post.timeLabel,
      imageUrl: post.imageUrls.first,
      location: '${post.upperRegion} ${post.lowerRegion}',
      placeTag: post.place?.name,
    );
  }

  static const List<HomeBanner> _mockBanners = [
    HomeBanner(
      id: 'banner-1',
      eyebrow: '로컬라이프',
      title: '한 달쯤, 여기서 살아볼까?',
      subtitle: '여행보다 오래, 이주보다 가볍게.\n나에게 맞는 지역에서 새로운 일상을 시작해보세요.',
      imageUrl: 'assets/images/home_carousel/page1.png',
    ),
    HomeBanner(
      id: 'banner-2',
      eyebrow: '정착가이드',
      title: '낯선 동네에서 살아가는 법',
      subtitle: '어디서 살고, 어디서 일하고, 어떻게 생활할까?\n지역 생활에 필요한 정보를 한곳에서 만나보세요.',
      imageUrl: 'assets/images/home_carousel/page2.png',
    ),
    HomeBanner(
      id: 'banner-3',
      eyebrow: '지역발견',
      title: '주말에 왔다가, 살고 싶어졌다',
      subtitle: '스쳐 지나가기엔 아쉬운 동네들.\n오래 머물수록 좋아지는 지역을 발견해보세요.',
      imageUrl: 'assets/images/home_carousel/page3.png',
    ),
  ];

  static final List<Category> _categories = List<Category>.unmodifiable([
    for (final CommunityCategory category in CommunityCategory.values)
      Category(
        id: category.name,
        label: category.label,
        backgroundColor: 0xFFF2F2F2,
        imageAssetPath: category.assetPath,
      ),
  ]);
}

final homeViewModelProvider =
    NotifierProvider.autoDispose<HomeViewModel, HomeState>(
      HomeViewModel.new,
    );
