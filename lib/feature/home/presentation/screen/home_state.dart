import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meomum/feature/home/domain/model/home_banner.dart';
import 'package:meomum/feature/home/domain/model/home_category.dart';
import 'package:meomum/feature/home/domain/model/home_feed_item.dart';

part 'home_state.freezed.dart';

@freezed
abstract class HomeState with _$HomeState {
  const factory HomeState({
    @Default([]) List<HomeBanner> banners,
    @Default([]) List<HomeCategory> categories,
    @Default([]) List<HomeFeedItem> feedItems,
    @Default(0) int currentBannerIndex,
  }) = _HomeState;
}
