import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/core/data/repository/auth/auth_repository_impl.dart';
import 'package:meomum/core/domain/enum/auth_session_status.dart';
import 'package:meomum/core/domain/repository/auth/auth_repository.dart';

/// 인증 세션 스트림을 앱 전역의 Listenable 상태로 변환한다.
class AuthSessionController extends ChangeNotifier {
  final AuthRepository _repository;
  late final StreamSubscription<AuthSessionStatus> _subscription;
  bool _isDisposed = false;

  AuthSessionController({required this._repository}) {
    _subscription = _repository.watchAuthState().listen((_) {
      if (!_isDisposed) {
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _subscription.cancel();
    super.dispose();
  }
}

final authSessionControllerProvider = Provider<AuthSessionController>((
  Ref ref,
) {
  final controller = AuthSessionController(
    repository: ref.watch(authRepositoryProvider),
  );
  ref.onDispose(controller.dispose);
  return controller;
});
