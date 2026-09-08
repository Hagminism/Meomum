import 'dart:io';

import 'package:meomum/core/data/dto/user/profile_dto.dart';
import 'package:meomum/core/domain/model/user/profile_image.dart';
import 'package:meomum/core/utils/result.dart';

abstract interface class ProfileDataSource {
  Future<Result<ProfileDto>> getProfile({required String accountId});

  Future<Result<ProfileDto>> updateProfile({
    required String accountId,
    required String nickname,
    String? profileImageUrl,
  });

  Future<Result<ProfileDto>> updateRegion({
    required String accountId,
    required String upperRegion,
    required String lowerRegion,
  });

  Future<Result<ProfileImage>> uploadProfileImage({
    required String accountId,
    required File file,
  });

  Future<Result<bool>> deleteProfileImage({required String storagePath});
}
