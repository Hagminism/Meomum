import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meomum/core/domain/model/category/category.dart';
import 'package:meomum/feature/home/domain/model/home_banner.dart';
import 'package:meomum/feature/home/domain/model/home_feed_item.dart';

part 'home_state.freezed.dart';

@freezed
abstract class HomeState with _$HomeState {
  const factory HomeState({
    @Default([]) List<HomeBanner> banners,
    @Default([]) List<Category> categories,
    @Default([]) List<HomeFeedItem> feedItems,
    @Default(0) int currentBannerIndex,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMore,
    @Default(true) bool hasMore,
  }) = _HomeState;
}
