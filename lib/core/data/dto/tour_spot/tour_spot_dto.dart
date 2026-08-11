import 'package:freezed_annotation/freezed_annotation.dart';

part 'tour_spot_dto.freezed.dart';
part 'tour_spot_dto.g.dart';

// TourAPI(KorService2) locationBasedList2 응답의 item 하나에 대응하는 원시 데이터.
@freezed
abstract class TourSpotDto with _$TourSpotDto {
  const factory TourSpotDto({
    @JsonKey(name: 'contentid') String? contentId,
    @JsonKey(name: 'contenttypeid') String? contentTypeId,
    String? title,
    String? addr1,
    String? addr2,
    @JsonKey(name: 'mapx') String? mapX,
    @JsonKey(name: 'mapy') String? mapY,
    String? dist,
    @JsonKey(name: 'firstimage') String? firstImage,
    @JsonKey(name: 'firstimage2') String? firstImage2,
    String? tel,
    String? cpyrhtDivCd,
  }) = _TourSpotDto;

  factory TourSpotDto.fromJson(Map<String, dynamic> json) =>
      _$TourSpotDtoFromJson(json);
}
