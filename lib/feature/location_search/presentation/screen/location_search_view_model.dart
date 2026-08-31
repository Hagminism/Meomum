import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/core/data/repository/naver_search/naver_search_repository_impl.dart';
import 'package:meomum/core/utils/result.dart';
import 'package:meomum/feature/location_search/presentation/screen/location_search_action.dart';
import 'package:meomum/feature/location_search/presentation/screen/location_search_event.dart';
import 'package:meomum/feature/location_search/presentation/screen/location_search_state.dart';

class LocationSearchViewModel extends Notifier<LocationSearchState> {
  @override
  LocationSearchState build() {
    ref.onDispose(() {
      _eventController.close();
    });

    return const LocationSearchState();
  }

  final StreamController<LocationSearchEvent> _eventController =
      StreamController<LocationSearchEvent>.broadcast();

  Stream<LocationSearchEvent> get eventStream => _eventController.stream;

  void onAction(LocationSearchAction action) {
    switch (action) {
      case ChangeQuery(:final query):
        state = state.copyWith(
          query: query,
          places: query.trim().isEmpty ? const [] : state.places,
          errorMessage: query.trim().isEmpty ? null : state.errorMessage,
        );
      case Search():
        _searchPlaces(state.query);
      case SelectPlace(:final place):
        _eventController.add(LocationSearchEvent.popWithPlace(place));
      case TapBack():
        _eventController.add(const LocationSearchEvent.pop());
    }
  }

  Future<void> _searchPlaces(String query) async {
    if (query.trim().isEmpty) {
      return;
    }

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    final naverSearchRepository = ref.read(naverSearchRepositoryProvider);
    final result = await naverSearchRepository.searchPlaces(
      query: query.trim(),
      display: 5,
    );

    switch (result) {
      case Success(:final data):
        state = state.copyWith(
          places: data,
          isLoading: false,
          errorMessage: data.isEmpty ? '검색 결과가 없습니다.' : null,
        );
      case Failure(:final message):
        state = state.copyWith(
          isLoading: false,
          errorMessage: '검색 중 오류가 발생했습니다: $message',
        );
    }
  }
}

final locationSearchViewModelProvider =
    NotifierProvider.autoDispose<LocationSearchViewModel, LocationSearchState>(
      LocationSearchViewModel.new,
    );
