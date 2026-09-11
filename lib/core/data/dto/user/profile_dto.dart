import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_dto.freezed.dart';
part 'profile_dto.g.dart';

@freezed
abstract class ProfileDto with _$ProfileDto {
  const factory ProfileDto({
    @JsonKey(name: 'account_id') required String accountId,
    required String nickname,
    @JsonKey(name: 'profile_image_url') String? profileImageUrl,
    @JsonKey(name: 'upper_region') String? upperRegion,
    @JsonKey(name: 'lower_region') String? lowerRegion,
  }) = _ProfileDto;

  factory ProfileDto.fromJson(Map<String, dynamic> json) =>
      _$ProfileDtoFromJson(json);
}
