import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/core/data/repository/auth/auth_repository_impl.dart';
import 'package:meomum/core/utils/result.dart';
import 'package:meomum/feature/my_page/presentation/screen/my_page_action.dart';
import 'package:meomum/feature/my_page/presentation/screen/my_page_event.dart';
import 'package:meomum/feature/my_page/presentation/screen/my_page_state.dart';

class MyPageViewModel extends Notifier<MyPageState> {
  @override
  MyPageState build() {
    ref.onDispose(() => _eventController.close());

    return const MyPageState();
  }

  final StreamController<MyPageEvent> _eventController =
      StreamController<MyPageEvent>.broadcast();

  Stream<MyPageEvent> get eventStream => _eventController.stream;

  void onAction(MyPageAction action) {
    switch (action) {
      case TapLogout():
        _signOut();
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
}

final myPageViewModelProvider =
    NotifierProvider.autoDispose<MyPageViewModel, MyPageState>(
      MyPageViewModel.new,
    );
