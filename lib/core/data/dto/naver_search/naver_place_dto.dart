import 'package:freezed_annotation/freezed_annotation.dart';

part 'naver_place_dto.freezed.dart';
part 'naver_place_dto.g.dart';

@freezed
abstract class NaverSearchResponseDto with _$NaverSearchResponseDto {
  const factory NaverSearchResponseDto({
    @Default([]) List<NaverPlaceDto> items,
    @Default(0) int total,
    @Default(1) int start,
    @Default(0) int display,
  }) = _NaverSearchResponseDto;

  factory NaverSearchResponseDto.fromJson(Map<String, dynamic> json) =>
      _$NaverSearchResponseDtoFromJson(json);
}

@freezed
abstract class NaverPlaceDto with _$NaverPlaceDto {
  const factory NaverPlaceDto({
    required String title,
    @Default('') String link,
    @Default('') String category,
    @Default('') String description,
    @Default('') String telephone,
    @Default('') String address,
    @Default('') String roadAddress,
    @Default('') String mapx,
    @Default('') String mapy,
  }) = _NaverPlaceDto;

  factory NaverPlaceDto.fromJson(Map<String, dynamic> json) =>
      _$NaverPlaceDtoFromJson(json);
}
