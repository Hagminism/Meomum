import 'package:freezed_annotation/freezed_annotation.dart';

part 'stay_history_item.freezed.dart';

@freezed
abstract class StayHistoryItem with _$StayHistoryItem {
  const factory StayHistoryItem({
    required String id,
    required String location,
    required String dateRange,
    String? thumbnailUrl,
  }) = _StayHistoryItem;
}
