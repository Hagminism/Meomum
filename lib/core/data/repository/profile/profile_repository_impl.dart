// The public constructor parameter intentionally initializes a private dependency.
// ignore_for_file: prefer_initializing_formals

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/core/data/data_source/profile/profile_data_source.dart';
import 'package:meomum/core/data/data_source/profile/profile_data_source_impl.dart';
import 'package:meomum/core/data/mapper/user/profile_mapper.dart';
import 'package:meomum/core/domain/model/user/profile.dart';
import 'package:meomum/core/domain/model/user/profile_image.dart';
import 'package:meomum/core/domain/repository/profile/profile_repository.dart';
import 'package:meomum/core/utils/result.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileDataSource _dataSource;

  ProfileRepositoryImpl({required ProfileDataSource dataSource})
    : _dataSource = dataSource;

  /// 데이터 소스에서 조회한 프로필 DTO를 도메인 모델로 변환해 반환합니다.
  @override
  Future<Result<Profile>> getProfile({required String accountId}) async {
    final result = await _dataSource.getProfile(accountId: accountId);

    return switch (result) {
      Success(data: final profile) => Result.success(profile.toModel()),
      Failure(message: final message) => Result.failure(message),
    };
  }

  /// 프로필 수정 결과를 도메인 모델로 변환해 반환합니다.
  @override
  Future<Result<Profile>> updateProfile({
    required String accountId,
    required String nickname,
    String? profileImageUrl,
  }) async {
    final result = await _dataSource.updateProfile(
      accountId: accountId,
      nickname: nickname,
      profileImageUrl: profileImageUrl,
    );

    return switch (result) {
      Success(data: final profile) => Result.success(profile.toModel()),
      Failure(message: final message) => Result.failure(message),
    };
  }

  /// 거주 지역 수정 결과를 도메인 모델로 변환해 반환합니다.
  @override
  Future<Result<Profile>> updateRegion({
    required String accountId,
    required String upperRegion,
    required String lowerRegion,
  }) async {
    final result = await _dataSource.updateRegion(
      accountId: accountId,
      upperRegion: upperRegion,
      lowerRegion: lowerRegion,
    );

    return switch (result) {
      Success(data: final profile) => Result.success(profile.toModel()),
      Failure(message: final message) => Result.failure(message),
    };
  }

  /// 프로필 이미지를 데이터 소스를 통해 Storage에 업로드합니다.
  @override
  Future<Result<ProfileImage>> uploadProfileImage({
    required String accountId,
    required File file,
  }) {
    return _dataSource.uploadProfileImage(accountId: accountId, file: file);
  }

  /// 데이터 소스를 통해 Storage의 프로필 이미지를 삭제합니다.
  @override
  Future<Result<bool>> deleteProfileImage({required String storagePath}) {
    return _dataSource.deleteProfileImage(storagePath: storagePath);
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((Ref ref) {
  return ProfileRepositoryImpl(
    dataSource: ref.watch(profileDataSourceProvider),
  );
});
