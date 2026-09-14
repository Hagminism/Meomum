import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/core/data/repository/auth/auth_repository_impl.dart';
import 'package:meomum/core/utils/result.dart';
import 'package:meomum/feature/settings_notice/data/mock/settings_notice_mock.dart';
import 'package:meomum/feature/settings/presentation/screen/settings_action.dart';
import 'package:meomum/feature/settings/presentation/screen/settings_event.dart';
import 'package:meomum/feature/settings/presentation/screen/settings_state.dart';

class SettingsViewModel extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    ref.onDispose(() => _eventController.close());

    return SettingsState(
      notices: settingsNoticeMockData,
    );
  }

  final StreamController<SettingsEvent> _eventController =
      StreamController<SettingsEvent>.broadcast();

  Stream<SettingsEvent> get eventStream => _eventController.stream;

  void onAction(SettingsAction action) {
    switch (action) {
      case TapBack():
        break;
      case TapNotices():
      case TapPrivacyPolicy():
      case TapLogout():
      case TapDeleteAccount():
        break;
    }
  }

  Future<void> signOut() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true);
    final authRepository = ref.read(authRepositoryProvider);
    final result = await authRepository.signOut();

    if (!ref.mounted) return;

    switch (result) {
      case Success():
        state = state.copyWith(isLoading: false);
      case Failure(message: final message):
        state = state.copyWith(isLoading: false);
        _eventController.add(SettingsEvent.showError(message));
    }
  }

  Future<void> deleteAccount() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true);
    final authRepository = ref.read(authRepositoryProvider);
    final result = await authRepository.deleteAccount();

    if (!ref.mounted) return;

    switch (result) {
      case Success():
        state = state.copyWith(isLoading: false);
      case Failure(message: final message):
        state = state.copyWith(isLoading: false);
        _eventController.add(SettingsEvent.showError(message));
    }
  }
}

final settingsViewModelProvider =
    NotifierProvider.autoDispose<SettingsViewModel, SettingsState>(
      SettingsViewModel.new,
    );
