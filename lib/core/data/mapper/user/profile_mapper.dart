import 'package:meomum/core/data/dto/user/profile_dto.dart';
import 'package:meomum/core/domain/model/user/profile.dart';

extension ProfileDtoMapper on ProfileDto {
  Profile toModel() {
    return Profile(
      accountId: accountId,
      nickname: nickname,
      profileImageUrl: profileImageUrl,
      upperRegion: upperRegion,
      lowerRegion: lowerRegion,
    );
  }
}
