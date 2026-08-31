import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meomum/feature/community/domain/model/community_place.dart';

part 'location_search_action.freezed.dart';

@freezed
sealed class LocationSearchAction with _$LocationSearchAction {
  const factory LocationSearchAction.changeQuery(String query) = ChangeQuery;
  const factory LocationSearchAction.search() = Search;
  const factory LocationSearchAction.selectPlace(CommunityPlace place) = SelectPlace;
  const factory LocationSearchAction.tapBack() = TapBack;
}
