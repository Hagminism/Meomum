import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meomum/core/presentation/component/dialog/two_button_dialog/two_button_dialog.dart';

void main() {
  testWidgets('두 버튼 다이얼로그가 버튼 선택 결과를 반환한다', (
    WidgetTester tester,
  ) async {
    bool? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (BuildContext context) {
            return ElevatedButton(
              onPressed: () async {
                result = await TwoButtonDialog.show(
                  context,
                  title: '작성 중인 내용이 있습니다.',
                  message: '저장하지 않고 나가시겠습니까?',
                  cancelLabel: '취소',
                  confirmLabel: '나가기',
                );
              },
              child: const Text('다이얼로그 열기'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('다이얼로그 열기'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('작성 중인 내용이 있습니다.'), findsOneWidget);
    expect(find.text('저장하지 않고 나가시겠습니까?'), findsOneWidget);

    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();

    expect(result, isFalse);

    await tester.tap(find.text('다이얼로그 열기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('나가기'));
    await tester.pumpAndSettle();

    expect(result, isTrue);
  });
}
