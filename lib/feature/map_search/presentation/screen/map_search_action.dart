import 'package:freezed_annotation/freezed_annotation.dart';

part 'map_search_action.freezed.dart';

@freezed
sealed class MapSearchAction with _$MapSearchAction {
  const factory MapSearchAction.queryChanged(String query) = QueryChanged;
  const factory MapSearchAction.searchSubmitted() = SearchSubmitted;
  const factory MapSearchAction.retryPressed() = RetryPressed;
  const factory MapSearchAction.backPressed() = BackPressed;
}
