import 'package:freezed_annotation/freezed_annotation.dart';

part 'tour_spot.freezed.dart';

@freezed
abstract class TourSpot with _$TourSpot {
  const factory TourSpot({
    required String id,
    required String title,
    required double latitude,
    required double longitude,
    String? address,
    double? distanceMeter,
    String? contentTypeId,
    String? thumbnailImageUrl,
    String? tel,
    String? copyrightDivisionCode,
  }) = _TourSpot;
}
