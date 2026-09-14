import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meomum/feature/settings_notice/presentation/component/settings_notice_entry_item.dart';
import 'package:meomum/feature/settings/presentation/screen/settings_action.dart';
import 'package:meomum/feature/settings/presentation/screen/settings_screen.dart';
import 'package:meomum/feature/settings/presentation/screen/settings_state.dart';

void main() {
  testWidgets('설정 화면에서 공지사항 페이지 이동 액션을 전달한다', (
    WidgetTester tester,
  ) async {
    SettingsAction? tappedAction;

    await tester.pumpWidget(
      MaterialApp(
        home: SettingsScreen(
          state: const SettingsState(),
          onAction: (SettingsAction action) {
            tappedAction = action;
          },
        ),
      ),
    );

    await tester.tap(find.byType(SettingsNoticeEntryItem));

    expect(tappedAction, const SettingsAction.tapNotices());
  });
}
