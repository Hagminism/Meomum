// The public constructor parameter intentionally initializes a private dependency.
// ignore_for_file: prefer_initializing_formals

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/core/data/data_source/profile/profile_data_source.dart';
import 'package:meomum/core/data/dto/user/profile_dto.dart';
import 'package:meomum/core/domain/model/user/profile_image.dart';
import 'package:meomum/core/utils/result.dart';
import 'package:meomum/di/di.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileDataSourceImpl implements ProfileDataSource {
  static const String _bucketName = 'profile-images';

  final SupabaseClient _client;

  ProfileDataSourceImpl({required SupabaseClient client}) : _client = client;

  /// 계정 식별자로 Supabase의 프로필 정보를 조회합니다.
  @override
  Future<Result<ProfileDto>> getProfile({required String accountId}) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('account_id', accountId)
          .single();

      return Result.success(ProfileDto.fromJson(response));
    } on PostgrestException catch (error) {
      return Result.failure('프로필을 불러오지 못했습니다: ${error.message}');
    } catch (error) {
      return Result.failure('프로필을 불러오는 중 오류가 발생했습니다: $error');
    }
  }

  /// 계정의 닉네임과 프로필 이미지 URL을 Supabase에 저장합니다.
  @override
  Future<Result<ProfileDto>> updateProfile({
    required String accountId,
    required String nickname,
    String? profileImageUrl,
  }) async {
    try {
      final response = await _client
          .from('profiles')
          .update({
            'nickname': nickname.trim(),
            'profile_image_url': profileImageUrl,
          })
          .eq('account_id', accountId)
          .select()
          .single();

      return Result.success(ProfileDto.fromJson(response));
    } on PostgrestException catch (error) {
      return Result.failure('프로필 저장에 실패했습니다: ${error.message}');
    } catch (error) {
      return Result.failure('프로필을 저장하는 중 오류가 발생했습니다: $error');
    }
  }

  /// 계정의 상위 지역과 하위 지역을 Supabase에 저장합니다.
  @override
  Future<Result<ProfileDto>> updateRegion({
    required String accountId,
    required String upperRegion,
    required String lowerRegion,
  }) async {
    try {
      final response = await _client
          .from('profiles')
          .update({
            'upper_region': upperRegion.trim(),
            'lower_region': lowerRegion.trim(),
          })
          .eq('account_id', accountId)
          .select()
          .single();

      return Result.success(ProfileDto.fromJson(response));
    } on PostgrestException catch (error) {
      return Result.failure('거주 지역 저장에 실패했습니다: ${error.message}');
    } catch (error) {
      return Result.failure('거주 지역을 저장하는 중 오류가 발생했습니다: $error');
    }
  }

  /// 프로필 이미지를 Storage에 업로드하고 저장 경로와 공개 URL을 반환합니다.
  @override
  Future<Result<ProfileImage>> uploadProfileImage({
    required String accountId,
    required File file,
  }) async {
    try {
      final timestamp = DateTime.now().microsecondsSinceEpoch;
      final extension = _extensionOf(file.path);
      final storagePath = 'accounts/$accountId/profile.$timestamp.$extension';

      await _client.storage
          .from(_bucketName)
          .upload(
            storagePath,
            file,
            fileOptions: FileOptions(
              contentType: _contentTypeOf(extension),
              upsert: false,
            ),
          );

      final publicUrl = _client.storage
          .from(_bucketName)
          .getPublicUrl(storagePath);

      return Result.success(
        ProfileImage(
          storagePath: storagePath,
          publicUrl: publicUrl,
        ),
      );
    } on StorageException catch (error) {
      return Result.failure('프로필 사진 업로드에 실패했습니다: ${error.message}');
    } catch (error) {
      return Result.failure('프로필 사진을 업로드하는 중 오류가 발생했습니다: $error');
    }
  }

  /// Storage에 저장된 프로필 이미지를 지정한 경로에서 삭제합니다.
  @override
  Future<Result<bool>> deleteProfileImage({
    required String storagePath,
  }) async {
    try {
      await _client.storage.from(_bucketName).remove([storagePath]);
      return const Result.success(true);
    } on StorageException catch (error) {
      return Result.failure('기존 프로필 사진 정리에 실패했습니다: ${error.message}');
    } catch (error) {
      return Result.failure('기존 프로필 사진을 정리하는 중 오류가 발생했습니다: $error');
    }
  }

  /// 파일 경로에서 지원하는 이미지 확장자를 확인하고 반환합니다.
  String _extensionOf(String path) {
    final extension = path.split('.').last.toLowerCase();
    return switch (extension) {
      'jpg' ||
      'jpeg' ||
      'png' ||
      'webp' => extension == 'jpeg' ? 'jpg' : extension,
      _ => 'jpg',
    };
  }

  /// 이미지 확장자에 맞는 MIME 타입을 반환합니다.
  String _contentTypeOf(String extension) {
    return switch (extension) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };
  }
}

final profileDataSourceProvider = Provider<ProfileDataSource>((Ref ref) {
  return ProfileDataSourceImpl(
    client: ref.watch(supabaseClientProvider),
  );
});
