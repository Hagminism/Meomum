import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meomum/feature/settings_notice/domain/model/settings_notice.dart';
import 'package:meomum/feature/settings_notice/presentation/screen/settings_notice_action.dart'
    as notice_action;
import 'package:meomum/feature/settings_notice/presentation/screen/settings_notice_screen.dart';

void main() {
  const notices = [
    SettingsNotice(
      id: 'notice-1',
      date: '26/09/14',
      title: '첫 번째 공지',
      content: '첫 번째 공지 내용',
    ),
    SettingsNotice(
      id: 'notice-2',
      date: '26/09/13',
      title: '두 번째 공지',
      content: '두 번째 공지 내용',
    ),
  ];

  testWidgets('공지사항은 한 번에 하나만 펼쳐진다', (WidgetTester tester) async {
    String? expandedNoticeId;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SettingsNoticeScreen(
              notices: notices,
              expandedNoticeId: expandedNoticeId,
              onAction: (notice_action.SettingsNoticeAction action) {
                switch (action) {
                  case notice_action.TapBack():
                    break;
                  case notice_action.ToggleNotice(:final id):
                    setState(() {
                      expandedNoticeId = expandedNoticeId == id ? null : id;
                    });
                }
              },
            );
          },
        ),
      ),
    );

    expect(find.text('첫 번째 공지 내용'), findsNothing);
    expect(find.text('두 번째 공지 내용'), findsNothing);

    await tester.tap(find.text('첫 번째 공지'));
    await tester.pumpAndSettle();

    expect(find.text('첫 번째 공지 내용'), findsOneWidget);
    expect(find.text('두 번째 공지 내용'), findsNothing);

    await tester.tap(find.text('두 번째 공지'));
    await tester.pumpAndSettle();

    expect(find.text('첫 번째 공지 내용'), findsNothing);
    expect(find.text('두 번째 공지 내용'), findsOneWidget);
  });
}
