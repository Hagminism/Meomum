import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_action.freezed.dart';

@freezed
sealed class HomeAction with _$HomeAction {
  const factory HomeAction.changeBannerIndex(int index) = ChangeBannerIndex;
  const factory HomeAction.tapCategory(String id) = TapCategory;
  const factory HomeAction.tapFeedItem(String id) = TapFeedItem;
}
