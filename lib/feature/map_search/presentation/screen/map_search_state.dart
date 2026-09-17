import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meomum/core/domain/model/commercial_store/commercial_store.dart';

part 'map_search_state.freezed.dart';

@freezed
abstract class MapSearchState with _$MapSearchState {
  const MapSearchState._();

  const factory MapSearchState({
    @Default('') String query,
    @Default(<CommercialStore>[]) List<CommercialStore> results,
    @Default(false) bool isLoading,
    @Default(false) bool hasSearched,
    String? errorMessage,
  }) = _MapSearchState;

  bool get isInitial => query.trim().isEmpty && !hasSearched;

  bool get isEmpty =>
      hasSearched && !isLoading && errorMessage == null && results.isEmpty;
}
