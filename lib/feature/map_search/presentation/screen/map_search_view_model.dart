import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/core/data/repository/commercial_store/commercial_store_repository_impl.dart';
import 'package:meomum/core/utils/result.dart';
import 'package:meomum/feature/map_search/presentation/screen/map_search_action.dart';
import 'package:meomum/feature/map_search/presentation/screen/map_search_state.dart';

class MapSearchViewModel extends Notifier<MapSearchState> {
  static const Duration searchDebounceDuration = Duration(milliseconds: 300);

  Timer? _searchDebounceTimer;
  int _requestGeneration = 0;

  @override
  MapSearchState build() {
    ref.onDispose(() {
      _searchDebounceTimer?.cancel();
    });

    return const MapSearchState();
  }

  void onAction(MapSearchAction action) {
    switch (action) {
      case QueryChanged(:final query):
        _changeQuery(query);
      case SearchSubmitted():
        unawaited(_searchImmediately());
      case RetryPressed():
        unawaited(_searchImmediately());
      case BackPressed():
        break;
    }
  }

  void _changeQuery(String query) {
    _searchDebounceTimer?.cancel();
    final generation = ++_requestGeneration;

    state = state.copyWith(
      query: query,
      results: const [],
      isLoading: query.trim().isNotEmpty,
      hasSearched: false,
      errorMessage: null,
    );

    if (query.trim().isEmpty) {
      return;
    }

    _searchDebounceTimer = Timer(searchDebounceDuration, () {
      unawaited(_search(query: query, generation: generation));
    });
  }

  Future<void> _searchImmediately() async {
    _searchDebounceTimer?.cancel();
    final query = state.query.trim();
    final generation = ++_requestGeneration;

    if (query.isEmpty) {
      state = state.copyWith(
        results: const [],
        isLoading: false,
        hasSearched: false,
        errorMessage: null,
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      hasSearched: false,
      errorMessage: null,
    );
    await _search(query: query, generation: generation);
  }

  Future<void> _search({
    required String query,
    required int generation,
  }) async {
    try {
      final result = await ref
          .read(commercialStoreRepositoryProvider)
          .searchStores(query: query);

      if (!ref.mounted || generation != _requestGeneration) return;

      switch (result) {
        case Success(:final data):
          state = state.copyWith(
            results: data,
            isLoading: false,
            hasSearched: true,
            errorMessage: null,
          );
        case Failure(:final message):
          state = state.copyWith(
            results: const [],
            isLoading: false,
            hasSearched: true,
            errorMessage: message,
          );
      }
    } catch (error) {
      if (!ref.mounted || generation != _requestGeneration) return;

      state = state.copyWith(
        results: const [],
        isLoading: false,
        hasSearched: true,
        errorMessage: '매장 검색에 실패했습니다. ($error)',
      );
    }
  }
}

final mapSearchViewModelProvider =
    NotifierProvider.autoDispose<MapSearchViewModel, MapSearchState>(
      MapSearchViewModel.new,
    );
