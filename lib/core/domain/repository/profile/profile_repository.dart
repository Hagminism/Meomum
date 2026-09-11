import 'dart:io';

import 'package:meomum/core/domain/model/user/profile.dart';
import 'package:meomum/core/domain/model/user/profile_image.dart';
import 'package:meomum/core/utils/result.dart';

abstract interface class ProfileRepository {
  Future<Result<Profile>> getProfile({required String accountId});

  Future<Result<Profile>> updateProfile({
    required String accountId,
    required String nickname,
    String? profileImageUrl,
  });

  Future<Result<Profile>> updateRegion({
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
