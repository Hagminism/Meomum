import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_feed_item.freezed.dart';
part 'home_feed_item.g.dart';

@freezed
abstract class HomeFeedItem with _$HomeFeedItem {
  const factory HomeFeedItem({
    required String id,
    required String category,
    required String title,
    required String content,
    required int likeCount,
    required int commentCount,
    required String timeLabel,
    String? imageUrl,
    String? location,
    String? placeTag,
  }) = _HomeFeedItem;

  factory HomeFeedItem.fromJson(Map<String, dynamic> json) =>
      _$HomeFeedItemFromJson(json);
}
