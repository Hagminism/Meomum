import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/feature/home/domain/model/home_banner.dart';
import 'package:meomum/feature/home/domain/model/home_category.dart';
import 'package:meomum/feature/home/domain/model/home_feed_item.dart';
import 'package:meomum/feature/home/presentation/screen/home_action.dart';
import 'package:meomum/feature/home/presentation/screen/home_event.dart';
import 'package:meomum/feature/home/presentation/screen/home_state.dart';

class HomeViewModel extends Notifier<HomeState> {
  @override
  HomeState build() {
    ref.onDispose(() => _eventController.close());

    return HomeState(
      banners: _mockBanners,
      categories: _mockCategories,
      feedItems: _mockFeedItems,
    );
  }

  final StreamController<HomeEvent> _eventController =
      StreamController<HomeEvent>.broadcast();

  Stream<HomeEvent> get eventStream => _eventController.stream;

  void onAction(HomeAction action) {
    switch (action) {
      case ChangeBannerIndex(:final index):
        state = state.copyWith(currentBannerIndex: index);
      case TapCategory(:final id):
        _eventController.add(
          HomeEvent.showMessage('카테고리($id)는 추후 연결 예정입니다.'),
        );
      case TapFeedItem(:final id):
        _eventController.add(
          HomeEvent.showMessage('게시글($id)은 추후 연결 예정입니다.'),
        );
    }
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
      subtitle:
          '새로운 지역에서 일상을 시작해보세요. 머뭄이 추천하는 한달살기 코스를 만나보세요.',
      imageUrl:
          'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=750&q=80',
    ),
    HomeBanner(
      id: 'banner-3',
      eyebrow: '매거진',
      title: '로컬과 함께하는 하루',
      subtitle:
          '현지인이 알려주는 숨은 맛집과 골목 산책 코스를 모아봤습니다.',
      imageUrl:
          'https://images.unsplash.com/photo-1488646953015-85ad3880ee66?w=750&q=80',
    ),
  ];

  static const List<HomeCategory> _mockCategories = [
    HomeCategory(
      id: 'category-1',
      label: '지역추천',
      backgroundColor: 0xFFE9F39B,
      imageUrl:
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=120&q=80',
    ),
    HomeCategory(
      id: 'category-2',
      label: '지역추천',
      backgroundColor: 0xFFF2F2F2,
    ),
    HomeCategory(
      id: 'category-3',
      label: '자유게시판',
      backgroundColor: 0xFFF2F2F2,
    ),
    HomeCategory(
      id: 'category-4',
      label: '일자리',
      backgroundColor: 0xFFF2F2F2,
    ),
    HomeCategory(
      id: 'category-5',
      label: '일자리',
      backgroundColor: 0xFFF2F2F2,
    ),
  ];

  static const List<HomeFeedItem> _mockFeedItems = [
    HomeFeedItem(
      id: 'feed-1',
      category: '카테고리',
      title: '한번 보면 어그로 제대로 끌려버릴 제목',
      content:
          'Lorem ipsum dolor sit amet consectetur. Viverra at urna duis tincidunt.',
      likeCount: 20,
      commentCount: 4,
      timeLabel: '20분 전',
      imageUrl:
          'https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=400&q=80',
    ),
    HomeFeedItem(
      id: 'feed-2',
      category: '카테고리',
      title: '한번 보면 어그로 제대로 끌려버릴 제목',
      content:
          'Lorem ipsum dolor sit amet consectetur. Viverra at urna duis tincidunt.',
      likeCount: 20,
      commentCount: 4,
      timeLabel: '20분 전',
      imageUrl:
          'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?w=400&q=80',
    ),
    HomeFeedItem(
      id: 'feed-3',
      category: '카테고리',
      title: '한번 보면 어그로 제대로 끌려버릴 제목',
      content:
          'Lorem ipsum dolor sit amet consectetur. Viverra at urna duis tincidunt.',
      likeCount: 20,
      commentCount: 4,
      timeLabel: '20분 전',
      imageUrl:
          'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=400&q=80',
    ),
    HomeFeedItem(
      id: 'feed-4',
      category: '카테고리',
      title: '한번 보면 어그로 제대로 끌려버릴 제목',
      content:
          'Lorem ipsum dolor sit amet consectetur. Viverra at urna duis tincidunt.',
      likeCount: 20,
      commentCount: 4,
      timeLabel: '20분 전',
      imageUrl:
          'https://images.unsplash.com/photo-1447752875215-b2761acb3c5d?w=400&q=80',
    ),
  ];
}

final homeViewModelProvider =
    NotifierProvider.autoDispose<HomeViewModel, HomeState>(
      HomeViewModel.new,
    );
