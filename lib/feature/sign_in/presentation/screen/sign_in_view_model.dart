import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/core/data/repository/auth/auth_repository_impl.dart';
import 'package:meomum/core/domain/enum/auth_provider.dart';
import 'package:meomum/core/utils/result.dart';
import 'package:meomum/feature/sign_in/presentation/screen/sign_in_action.dart';
import 'package:meomum/feature/sign_in/presentation/screen/sign_in_event.dart';
import 'package:meomum/feature/sign_in/presentation/screen/sign_in_state.dart';

class SignInViewModel extends Notifier<SignInState> {
  @override
  SignInState build() {
    ref.onDispose(() => _eventController.close());

    return const SignInState();
  }

  final StreamController<SignInEvent> _eventController =
      StreamController<SignInEvent>.broadcast();

  Stream<SignInEvent> get eventStream => _eventController.stream;

  void onAction(SignInAction action) {
    switch (action) {
      case TapGoogle():
        _signIn(AuthProvider.google);
      case TapApple():
        _eventController.add(
          const SignInEvent.showMessage('애플 로그인은 추후 지원 예정입니다.'),
        );
      case TapKakao():
        _signIn(AuthProvider.kakao);
      case TapNaver():
        _signIn(AuthProvider.naver);
    }
  }

  Future<void> _signIn(AuthProvider provider) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, errorMessage: null);
    final authRepository = ref.read(authRepositoryProvider);

    final result = await authRepository.signInWithOAuth(provider);

    switch (result) {
      case Success():
        // 로그인 성공 후 홈 화면 이동 전 시각적 전달과 타 로그인 버튼 중복 클릭을 방지
        return;
      case Failure(:final message):
        state = state.copyWith(isLoading: false, errorMessage: message);
        _eventController.add(SignInEvent.showError(message));
    }
  }
}

final signInViewModelProvider =
    NotifierProvider.autoDispose<SignInViewModel, SignInState>(
      SignInViewModel.new,
    );
