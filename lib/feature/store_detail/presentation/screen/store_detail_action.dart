import 'package:freezed_annotation/freezed_annotation.dart';

part 'store_detail_action.freezed.dart';

@freezed
sealed class StoreDetailAction with _$StoreDetailAction {
  const factory StoreDetailAction.tapBack() = TapBack;
  const factory StoreDetailAction.tapNaverMap() = TapNaverMap;
  const factory StoreDetailAction.tapRetry() = TapRetry;
}
