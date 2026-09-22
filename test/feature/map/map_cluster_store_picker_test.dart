import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meomum/core/domain/model/commercial_store/commercial_store.dart';
import 'package:meomum/feature/map/presentation/component/map_cluster_store_picker.dart';
import 'package:meomum/feature/map/presentation/screen/map_screen.dart';
import 'package:meomum/feature/map/presentation/screen/map_state.dart';

void main() {
  const stores = [
    CommercialStore(
      id: 'store-1',
      name: '머뭄 카페',
      latitude: 37.5666,
      longitude: 126.979,
      branchName: '시청점',
      address: '서울특별시 중구 세종대로 1',
    ),
    CommercialStore(
      id: 'store-2',
      name: '머뭄 식당',
      latitude: 37.5666,
      longitude: 126.979,
      branchName: '시청점',
      address: '서울특별시 중구 세종대로 1',
    ),
  ];

  testWidgets('중복 위치 매장을 목록에서 선택할 수 있다', (tester) async {
    CommercialStore? selectedStore;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 360,
            height: 640,
            child: MapClusterStorePicker(
              stores: stores,
              onStoreSelected: (store) {
                selectedStore = store;
              },
              onDismiss: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('이 위치의 매장'), findsOneWidget);
    expect(find.text('2곳'), findsOneWidget);
    expect(find.text('머뭄 카페시청점'), findsOneWidget);
    expect(find.text('머뭄 식당시청점'), findsOneWidget);

    await tester.tap(find.text('머뭄 식당시청점'));
    await tester.pump();

    expect(selectedStore, stores[1]);
  });

  testWidgets('중복 위치 매장 목록을 닫을 수 있다', (tester) async {
    var dismissed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MapClusterStorePicker(
            stores: stores,
            onStoreSelected: (_) {},
            onDismiss: () {
              dismissed = true;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('매장 목록 닫기'));
    await tester.pump();

    expect(dismissed, isTrue);
  });

  testWidgets('지도 핀 옆에서 매장 목록이 레이아웃 오류 없이 표시된다', (tester) async {
    final thirdStore = stores[0].copyWith(id: 'store-3', name: '머뭄 서점');
    final clusterStores = [...stores, thirdStore];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              Positioned(
                left: 16,
                top: 120,
                width: 240,
                child: MapClusterStorePicker(
                  stores: clusterStores,
                  onStoreSelected: (_) {},
                  onDismiss: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('머뭄 서점시청점'), findsOneWidget);
  });

  testWidgets('지도 화면의 핀 옆 목록이 Stack 위치에 맞게 배치된다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MapScreen(
          mapView: const ColoredBox(color: Colors.white),
          state: const MapState(isMapReady: true),
          onAction: (_) {},
          onStoreSelected: (_) {},
          selectedClusterStores: stores,
          selectedClusterOffset: const Offset(180, 336),
          onClusterSelectionDismissed: () {},
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    final headerRect = tester.getRect(find.text('이 위치의 매장'));

    expect(headerRect.top, greaterThan(16));
  });
}
