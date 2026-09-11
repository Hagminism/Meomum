import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meomum/feature/community/domain/model/community_place.dart';

part 'location_search_state.freezed.dart';

@freezed
abstract class LocationSearchState with _$LocationSearchState {
  const factory LocationSearchState({
    @Default('') String query,
    @Default([]) List<CommunityPlace> places,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _LocationSearchState;
}
