import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meomum/core/domain/model/commercial_store/commercial_store.dart';
import 'package:meomum/feature/map_search/presentation/screen/map_search_action.dart';
import 'package:meomum/feature/map_search/presentation/screen/map_search_screen.dart';
import 'package:meomum/feature/map_search/presentation/screen/map_search_state.dart';

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

  testWidgets('검색 결과 매장을 선택하면 상세 선택 콜백을 호출한다', (
    WidgetTester tester,
  ) async {
    CommercialStore? selectedStore;

    await tester.pumpWidget(
      MaterialApp(
        home: MapSearchScreen(
          state: const MapSearchState(
            query: '머뭄',
            results: [store],
            hasSearched: true,
          ),
          onAction: (MapSearchAction action) {},
          onStoreSelected: (CommercialStore value) {
            selectedStore = value;
          },
        ),
      ),
    );

    expect(find.text('머뭄 카페시청점'), findsOneWidget);
    expect(find.text('서울특별시 중구 세종대로 1'), findsOneWidget);

    await tester.tap(find.text('머뭄 카페시청점'));
    await tester.pump();

    expect(selectedStore, store);
  });

  testWidgets('검색어를 입력하면 queryChanged 액션을 전달한다', (
    WidgetTester tester,
  ) async {
    final actions = <MapSearchAction>[];

    await tester.pumpWidget(
      MaterialApp(
        home: MapSearchScreen(
          state: const MapSearchState(),
          onAction: (MapSearchAction action) {
            actions.add(action);
          },
        ),
      ),
    );

    await tester.enterText(find.byType(EditableText), '영등포');

    expect(actions, [const MapSearchAction.queryChanged('영등포')]);
  });

  testWidgets('검색 오류 상태에서 원시 오류 대신 다시 시도 액션을 전달한다', (
    WidgetTester tester,
  ) async {
    final actions = <MapSearchAction>[];
    const rawError = '데이터베이스 조회에 실패했습니다: statement timeout';

    await tester.pumpWidget(
      MaterialApp(
        home: MapSearchScreen(
          state: const MapSearchState(
            query: '영등포역',
            hasSearched: true,
            errorMessage: rawError,
          ),
          onAction: (MapSearchAction action) {
            actions.add(action);
          },
        ),
      ),
    );

    expect(find.text(rawError), findsNothing);
    expect(find.text('검색을 불러오지 못했어요.'), findsOneWidget);

    await tester.tap(find.text('다시 시도'));
    await tester.pump();

    expect(actions, [const MapSearchAction.retryPressed()]);
  });
}
