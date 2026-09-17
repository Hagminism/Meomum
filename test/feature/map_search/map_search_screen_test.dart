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

  testWidgets('검색 결과 매장은 터치 피드백만 제공한다', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MapSearchScreen(
          state: const MapSearchState(
            query: '머뭄',
            results: [store],
            hasSearched: true,
          ),
          onAction: (MapSearchAction action) {},
        ),
      ),
    );

    expect(find.text('머뭄 카페'), findsOneWidget);
    expect(find.text('시청점'), findsOneWidget);
    expect(find.text('서울특별시 중구 세종대로 1'), findsOneWidget);

    await tester.tap(find.text('머뭄 카페'));
    await tester.pump();

    expect(find.text('머뭄 카페'), findsOneWidget);
  });
}
