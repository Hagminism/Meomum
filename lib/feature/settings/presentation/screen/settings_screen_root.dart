import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meomum/core/presentation/component/app_snackbar.dart';
import 'package:meomum/core/presentation/component/dialog/two_button_dialog/two_button_dialog.dart';
import 'package:meomum/core/routing/routes.dart';
import 'package:meomum/feature/settings/presentation/screen/settings_action.dart';
import 'package:meomum/feature/settings/presentation/screen/settings_event.dart';
import 'package:meomum/feature/settings/presentation/screen/settings_screen.dart';
import 'package:meomum/feature/settings/presentation/screen/settings_view_model.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreenRoot extends ConsumerStatefulWidget {
  const SettingsScreenRoot({super.key});

  @override
  ConsumerState<SettingsScreenRoot> createState() => _SettingsScreenRootState();
}

class _SettingsScreenRootState extends ConsumerState<SettingsScreenRoot> {
  static final Uri _privacyPolicyUri = Uri.parse(
    'https://app.notion.com/p/3baf5b5d5eb48051adccda213145fbdf?source=copy_link',
  );

  StreamSubscription<SettingsEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final viewModel = ref.read(settingsViewModelProvider.notifier);
      _eventSubscription = viewModel.eventStream.listen((SettingsEvent event) {
        if (!mounted) return;

        switch (event) {
          case ShowError(:final message):
            AppSnackBar.showError(context, message);
          case ShowMessage(:final message):
            AppSnackBar.showInfo(context, message);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settingsViewModelProvider);

    return SettingsScreen(
      state: state,
      onAction: (SettingsAction action) {
        switch (action) {
          case TapBack():
            context.pop();
          case TapNotices():
            context.push(
              '${Routes.myPage}/${Routes.myPageSettings}/${Routes.myPageSettingsNotices}',
            );
          case TapPrivacyPolicy():
            unawaited(_openPrivacyPolicy());
          case TapLogout():
            unawaited(_confirmLogout());
          case TapDeleteAccount():
            unawaited(_confirmDeleteAccount());
        }
      },
    );
  }

  Future<void> _openPrivacyPolicy() async {
    final didLaunch = await launchUrl(
      _privacyPolicyUri,
      mode: LaunchMode.externalApplication,
    );
    if (!mounted || didLaunch) return;

    AppSnackBar.showError(context, '개인정보처리방침을 열 수 없습니다.');
  }

  Future<void> _confirmLogout() async {
    if (!mounted || ref.read(settingsViewModelProvider).isLoading) return;

    final shouldConfirm = await TwoButtonDialog.show(
      context,
      title: '로그아웃할까요?',
      message: '로그아웃하면 다시 로그인해야 합니다.',
      confirmLabel: '로그아웃',
    );
    if (!mounted || !shouldConfirm) return;

    await ref.read(settingsViewModelProvider.notifier).signOut();
  }

  Future<void> _confirmDeleteAccount() async {
    if (!mounted || ref.read(settingsViewModelProvider).isLoading) return;

    final shouldConfirm = await TwoButtonDialog.show(
      context,
      title: '회원 탈퇴할까요?',
      message: '탈퇴하면 프로필과 작성한 게시글이 모두 삭제되며 복구할 수 없습니다.',
      confirmLabel: '탈퇴하기',
    );
    if (!mounted || !shouldConfirm) return;

    await ref.read(settingsViewModelProvider.notifier).deleteAccount();
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }
}
