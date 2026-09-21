import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_page_promotion.freezed.dart';
part 'my_page_promotion.g.dart';

@freezed
abstract class MyPagePromotion with _$MyPagePromotion {
  const factory MyPagePromotion({
    required String id,
    required String eyebrow,
    required String title,
    required String subtitle,
    required String imageAssetPath,
  }) = _MyPagePromotion;

  factory MyPagePromotion.fromJson(Map<String, dynamic> json) =>
      _$MyPagePromotionFromJson(json);
}
