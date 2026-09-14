import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meomum/feature/settings_notice/presentation/screen/settings_notice_action.dart';
import 'package:meomum/feature/settings_notice/presentation/screen/settings_notice_screen.dart';
import 'package:meomum/feature/settings/presentation/screen/settings_view_model.dart';

class SettingsNoticeScreenRoot extends ConsumerStatefulWidget {
  const SettingsNoticeScreenRoot({super.key});

  @override
  ConsumerState<SettingsNoticeScreenRoot> createState() =>
      _SettingsNoticeScreenRootState();
}

class _SettingsNoticeScreenRootState
    extends ConsumerState<SettingsNoticeScreenRoot> {
  String? _expandedNoticeId;

  @override
  Widget build(BuildContext context) {
    final notices = ref.watch(settingsViewModelProvider).notices;

    return SettingsNoticeScreen(
      notices: notices,
      expandedNoticeId: _expandedNoticeId,
      onAction: (SettingsNoticeAction action) {
        switch (action) {
          case TapBack():
            context.pop();
          case ToggleNotice(:final id):
            setState(() {
              _expandedNoticeId = _expandedNoticeId == id ? null : id;
            });
        }
      },
    );
  }
}
