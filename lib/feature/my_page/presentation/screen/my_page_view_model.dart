import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/core/data/repository/auth/auth_repository_impl.dart';
import 'package:meomum/core/domain/model/category/category.dart';
import 'package:meomum/core/utils/result.dart';
import 'package:meomum/feature/my_page/domain/model/current_stay.dart';
import 'package:meomum/feature/my_page/domain/model/stay_history_item.dart';
import 'package:meomum/feature/my_page/presentation/screen/my_page_action.dart';
import 'package:meomum/feature/my_page/presentation/screen/my_page_event.dart';
import 'package:meomum/feature/my_page/presentation/screen/my_page_state.dart';

class MyPageViewModel extends Notifier<MyPageState> {
  @override
  MyPageState build() {
    ref.onDispose(() => _eventController.close());

    final authRepository = ref.read(authRepositoryProvider);

    return MyPageState(
      user: authRepository.currentUser,
      currentStay: _mockCurrentStay,
      categories: _mockCategories,
      stayHistories: _mockStayHistories,
    );
  }

  final StreamController<MyPageEvent> _eventController =
      StreamController<MyPageEvent>.broadcast();

  Stream<MyPageEvent> get eventStream => _eventController.stream;

  void onAction(MyPageAction action) {
    switch (action) {
      case TapMyFeed():
        _eventController.add(const MyPageEvent.showMessage('내 피드는 추후 연결 예정입니다.'));
      case TapProfile():
        _eventController.add(const MyPageEvent.showMessage('프로필은 추후 연결 예정입니다.'));
      case TapCurrentStayMenu():
        _eventController.add(
          const MyPageEvent.showMessage('현재 머무는 중 메뉴는 추후 연결 예정입니다.'),
        );
      case TapCategory(:final id):
        _eventController.add(
          MyPageEvent.showMessage('카테고리($id)는 추후 연결 예정입니다.'),
        );
      case TapStayHistory(:final id):
        _eventController.add(
          MyPageEvent.showMessage('머문 기록($id)은 추후 연결 예정입니다.'),
        );
      case TapStayHistoryMenu(:final id):
        _eventController.add(
          MyPageEvent.showMessage('머문 기록($id) 메뉴는 추후 연결 예정입니다.'),
        );
      case TapLogout():
        _signOut();
      case TapSettings():
        break; // root에서 처리
    }
  }

  Future<void> _signOut() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true);
    final authRepository = ref.read(authRepositoryProvider);

    final result = await authRepository.signOut();
    if (!ref.mounted) return;

    switch (result) {
      case Success():
        state = state.copyWith(isLoading: false);
      case Failure(:final message):
        state = state.copyWith(isLoading: false);
        _eventController.add(MyPageEvent.showError(message));
    }
  }

  static const CurrentStay _mockCurrentStay = CurrentStay(
    location: '경상북도 포항시',
    dateRange: '6월 30일 - 7월 20일',
    jobType: '일자리',
    accommodation: '숙소',
    thumbnailUrl:
        'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=144&q=80',
  );

  static const List<Category> _mockCategories = [
    Category(
      id: 'category-1',
      label: '지역추천',
      backgroundColor: 0xFFE9F39B,
      imageUrl:
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=120&q=80',
    ),
    Category(
      id: 'category-2',
      label: '자유게시판',
      backgroundColor: 0xFFF2F2F2,
    ),
    Category(
      id: 'category-3',
      label: '일자리',
      backgroundColor: 0xFFF2F2F2,
    ),
    Category(
      id: 'category-4',
      label: '지역추천',
      backgroundColor: 0xFFF2F2F2,
    ),
    Category(
      id: 'category-5',
      label: '일자리',
      backgroundColor: 0xFFF2F2F2,
    ),
  ];

  static const List<StayHistoryItem> _mockStayHistories = [
    StayHistoryItem(
      id: 'stay-1',
      location: '전라남도 순천시',
      dateRange: '2026년 6월 30일 - 2026년 7월 20일',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?w=120&q=80',
    ),
    StayHistoryItem(
      id: 'stay-2',
      location: '강원도 강릉시',
      dateRange: '2026년 6월 30일 - 2026년 7월 20일',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=120&q=80',
    ),
    StayHistoryItem(
      id: 'stay-3',
      location: '경기도 파주시',
      dateRange: '2026년 6월 30일 - 2026년 7월 20일',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1447752875215-b2761acb3c5d?w=120&q=80',
    ),
  ];
}

final myPageViewModelProvider =
    NotifierProvider.autoDispose<MyPageViewModel, MyPageState>(
      MyPageViewModel.new,
    );
