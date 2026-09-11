import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/core/data/repository/community/community_post_repository_impl.dart';
import 'package:meomum/core/domain/repository/community/community_post_repository.dart';

class CommunityImageCleanupLifecycle {
  final CommunityPostRepository _repository;
  late final AppLifecycleListener _lifecycleListener;

  bool _isRunning = false;
  DateTime? _lastAttemptAt;

  CommunityImageCleanupLifecycle(this._repository) {
    _lifecycleListener = AppLifecycleListener(
      onResume: _onResume,
    );
    unawaited(runNow());
  }

  Future<void> runNow({bool force = false}) async {
    if (_isRunning) return;

    final lastAttemptAt = _lastAttemptAt;
    if (!force &&
        lastAttemptAt != null &&
        DateTime.now().difference(lastAttemptAt) <
            const Duration(seconds: 30)) {
      return;
    }

    _isRunning = true;
    _lastAttemptAt = DateTime.now();
    try {
      await _repository.retryPendingImageCleanup();
    } finally {
      _isRunning = false;
    }
  }

  void _onResume() {
    unawaited(runNow());
  }

  void dispose() {
    _lifecycleListener.dispose();
  }
}

final communityImageCleanupLifecycleProvider =
    Provider<CommunityImageCleanupLifecycle>((Ref ref) {
      final lifecycle = CommunityImageCleanupLifecycle(
        ref.watch(communityPostRepositoryProvider),
      );
      ref.onDispose(lifecycle.dispose);
      return lifecycle;
    });
