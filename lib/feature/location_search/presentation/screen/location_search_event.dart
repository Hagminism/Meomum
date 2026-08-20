import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meomum/feature/community/domain/model/community_place.dart';

part 'location_search_event.freezed.dart';

@freezed
sealed class LocationSearchEvent with _$LocationSearchEvent {
  const factory LocationSearchEvent.popWithPlace(CommunityPlace place) = PopWithPlace;
  const factory LocationSearchEvent.pop() = Pop;
  const factory LocationSearchEvent.showMessage(String message) = ShowMessage;
}
