import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meomum/core/domain/model/commercial_store/commercial_store.dart';
import 'package:meomum/feature/store_detail/presentation/component/store_detail_web_view.dart';
import 'package:meomum/feature/store_detail/presentation/screen/store_detail_action.dart';
import 'package:meomum/feature/store_detail/presentation/screen/store_detail_state.dart';
import 'package:meomum/feature/store_detail/presentation/screen/store_detail_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'fake_web_view_platform.dart';

void main() {
  const store = CommercialStore(
    id: 'store-1',
    name: '머뭄 카페',
    latitude: 37.5666,
    longitude: 126.979,
    branchName: '시청점',
    industryLargeName: '음식점',
    address: '서울특별시 중구 세종대로 1',
  );

  setUp(() {
    WebViewPlatform.instance = FakeWebViewPlatform();
  });

  testWidgets('매장 정보와 네이버 검색 WebView를 표시한다', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(375, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final actions = <StoreDetailAction>[];

    await tester.pumpWidget(
      MaterialApp(
        home: StoreDetailScreen(
          store: store,
          webViewController: WebViewController(),
          state: const StoreDetailState(),
          onAction: actions.add,
        ),
      ),
    );

    expect(find.text('머뭄 카페시청점'), findsOneWidget);
    expect(find.byIcon(Icons.location_on_outlined), findsNothing);
    expect(find.byType(StoreDetailWebView), findsOneWidget);

    await tester.tap(find.byTooltip('네이버 지도에서 열기'));
    await tester.tap(find.byTooltip('이전 화면으로 돌아가기'));

    expect(actions, contains(const StoreDetailAction.tapNaverMap()));
    expect(actions, contains(const StoreDetailAction.tapBack()));
  });
}
