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
      case TapFeedItem(:final id):
        _eventController.add(
          HomeEvent.showMessage('게시글($id)은 추후 연결 예정입니다.'),
        );
      case LoadMore():
        _loadMore();
    }
  }

  Future<void> _fetchInitialPosts() async {
    _cursor = null;
    state = state.copyWith(
      feedItems: const [],
      isLoading: true,
      isLoadingMore: false,
      hasMore: true,
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
          hasMore: posts.length >= _pageSize,
        );
      case Failure(message: final message):
        state = state.copyWith(isLoading: false);
        _eventController.add(HomeEvent.showMessage(message));
    }
  }

  Future<void> _loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) {
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
      eyebrow: '매거진',
      title: '대한민국 구석구석',
      subtitle:
          'Lorem ipsum dolor sit amet consectetur. Viverra at urna duis tincidunt. Quis nec aliquam amet quis.',
      imageUrl:
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=750&q=80',
    ),
    HomeBanner(
      id: 'banner-2',
      eyebrow: '매거진',
      title: '한달살기의 시작',
      subtitle: '새로운 지역에서 일상을 시작해보세요. 머뭄이 추천하는 한달살기 코스를 만나보세요.',
      imageUrl:
          'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=750&q=80',
    ),
    HomeBanner(
      id: 'banner-3',
      eyebrow: '매거진',
      title: '로컬과 함께하는 하루',
      subtitle: '현지인이 알려주는 숨은 맛집과 골목 산책 코스를 모아봤습니다.',
      imageUrl:
          'https://images.unsplash.com/photo-1488646953015-85ad3880ee66?w=750&q=80',
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
