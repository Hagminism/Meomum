import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/core/domain/model/commercial_store/commercial_store.dart';
import 'package:meomum/core/domain/model/location/geo_location.dart';
import 'package:meomum/core/domain/repository/commercial_store/commercial_store_repository.dart';
import 'package:meomum/core/utils/result.dart';
import 'package:meomum/core/data/repository/commercial_store/commercial_store_repository_impl.dart';
import 'package:meomum/feature/map_search/presentation/screen/map_search_action.dart';
import 'package:meomum/feature/map_search/presentation/screen/map_search_view_model.dart';

void main() {
  test('입력을 멈춘 뒤 debounce가 끝나야 서버 검색을 요청한다', () async {
    final repository = _FakeCommercialStoreRepository();
    final container = ProviderContainer(
      overrides: [
        commercialStoreRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(
      mapSearchViewModelProvider,
      (_, _) {},
    );
    addTearDown(subscription.close);

    final viewModel = container.read(mapSearchViewModelProvider.notifier);
    viewModel.onAction(const MapSearchAction.queryChanged('카페'));

    await Future<void>.delayed(
      MapSearchViewModel.searchDebounceDuration -
          const Duration(milliseconds: 50),
    );
    expect(repository.searchQueries, isEmpty);

    await Future<void>.delayed(const Duration(milliseconds: 75));
    expect(repository.searchQueries, ['카페']);
  });

  test('새 검색의 응답이 이전 검색 결과를 덮어쓰지 않는다', () async {
    final repository = _FakeCommercialStoreRepository();
    final container = ProviderContainer(
      overrides: [
        commercialStoreRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(
      mapSearchViewModelProvider,
      (_, _) {},
    );
    addTearDown(subscription.close);

    final viewModel = container.read(mapSearchViewModelProvider.notifier);
    viewModel.onAction(const MapSearchAction.queryChanged('첫 검색'));
    await Future<void>.delayed(MapSearchViewModel.searchDebounceDuration);

    viewModel.onAction(const MapSearchAction.queryChanged('두 번째 검색'));
    await Future<void>.delayed(MapSearchViewModel.searchDebounceDuration);

    repository.completers['첫 검색']!.complete(
      const Result.success([
        CommercialStore(
          id: 'old',
          name: '이전 결과',
          latitude: 37.0,
          longitude: 127.0,
        ),
      ]),
    );
    await Future<void>.delayed(Duration.zero);
    expect(viewModel.state.results, isEmpty);

    repository.completers['두 번째 검색']!.complete(
      const Result.success([
        CommercialStore(
          id: 'new',
          name: '최신 결과',
          latitude: 37.0,
          longitude: 127.0,
        ),
      ]),
    );
    await Future<void>.delayed(Duration.zero);

    expect(viewModel.state.results.single.name, '최신 결과');
  });
}

class _FakeCommercialStoreRepository implements CommercialStoreRepository {
  final List<String> searchQueries = <String>[];
  final Map<String, Completer<Result<List<CommercialStore>>>> completers =
      <String, Completer<Result<List<CommercialStore>>>>{};

  @override
  Future<Result<List<CommercialStore>>> getNearbyStores({
    required GeoLocation location,
    required int radius,
  }) async {
    return const Result.success(<CommercialStore>[]);
  }

  @override
  Future<Result<List<CommercialStore>>> searchStores({
    required String query,
  }) {
    searchQueries.add(query);
    final completer = Completer<Result<List<CommercialStore>>>();
    completers[query] = completer;
    return completer.future;
  }
}
