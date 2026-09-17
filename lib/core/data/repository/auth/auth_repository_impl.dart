// The public constructor parameter intentionally initializes a private dependency.
// ignore_for_file: prefer_initializing_formals

import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/core/data/data_source/auth/auth_data_source.dart';
import 'package:meomum/core/data/data_source/auth/auth_data_source_impl.dart';
import 'package:meomum/core/data/repository/profile/profile_repository_impl.dart';
import 'package:meomum/core/data/storage/storage_bucket.dart';
import 'package:meomum/core/domain/enum/auth_provider.dart';
import 'package:meomum/core/domain/enum/auth_session_status.dart';
import 'package:meomum/core/domain/model/user/auth_identity.dart';
import 'package:meomum/core/domain/model/user/profile.dart';
import 'package:meomum/core/domain/model/user/user.dart';
import 'package:meomum/core/domain/repository/auth/auth_repository.dart';
import 'package:meomum/core/domain/repository/profile/profile_repository.dart';
import 'package:meomum/core/domain/repository/storage_cleanup/storage_cleanup_repository.dart';
import 'package:meomum/core/data/repository/storage_cleanup/storage_cleanup_repository_impl.dart';
import 'package:meomum/core/utils/result.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _dataSource;
  final ProfileRepository _profileRepository;
  final StorageCleanupRepository _storageCleanupRepository;

  late final Future<void> _restoreFuture;
  final StreamController<AuthSessionStatus> _authStateController =
      StreamController<AuthSessionStatus>.broadcast();
  User? _currentUser;
  bool _isInitialized = false;
  String? _sessionErrorMessage;

  AuthRepositoryImpl({
    required this._dataSource,
    required this._profileRepository,
    required StorageCleanupRepository storageCleanupRepository,
  }) : _storageCleanupRepository = storageCleanupRepository {
    _restoreFuture = _restoreSession();
  }

  /// OAuth 인증 결과를 앱 사용자로 완성하고 인증 상태를 signed-in으로 전파합니다.
  @override
  Future<Result<bool>> signInWithOAuth(AuthProvider provider) async {
    final result = await _dataSource.signInWithOAuth(provider);

    return switch (result) {
      Success(data: final identity) => await _completeSignIn(identity),
      Failure(message: final message) => Result.failure(message),
    };
  }

  /// 인증 데이터 소스에서 로그아웃한 뒤 앱 내부 사용자와 인증 상태를 초기화합니다.
  @override
  Future<Result<bool>> signOut() async {
    final result = await _dataSource.signOut();

    if (result case Success()) {
      _currentUser = null;
      _sessionErrorMessage = null;
      _authStateController.add(AuthSessionStatus.signedOut);
    }

    return result;
  }

  /// 계정 삭제가 완료된 경우 앱 내부 사용자와 인증 상태를 signed-out으로 초기화합니다.
  @override
  Future<Result<bool>> deleteAccount() async {
    final result = await _dataSource.deleteAccount();

    if (result case Success()) {
      _currentUser = null;
      _sessionErrorMessage = null;
      _authStateController.add(AuthSessionStatus.signedOut);
    }

    return result;
  }

  /// 세션 복원 결과를 먼저 전달한 뒤 이후 인증 상태 변경을 스트림으로 제공합니다.
  @override
  Stream<AuthSessionStatus> watchAuthState() {
    return _watchAuthState();
  }

  /// 인증 상태를 초기화하고 저장된 세션 복원을 다시 시도합니다.
  @override
  Future<void> retrySessionRestore() async {
    _isInitialized = false;
    _sessionErrorMessage = null;
    _authStateController.add(AuthSessionStatus.initializing);
    await _restoreSession();
  }

  @override
  String? get sessionErrorMessage => _sessionErrorMessage;

  /// 현재 사용자 정보와 프로필 이미지 변경을 저장하고 이전 이미지는 서버 정리 큐에 등록합니다.
  @override
  Future<Result<User>> updateProfile({
    required String nickname,
    File? profileImage,
  }) async {
    final currentUser = _currentUser;
    if (currentUser == null) {
      return const Result.failure('로그인 후 프로필을 수정할 수 있습니다.');
    }

    final trimmedNickname = nickname.trim();
    if (trimmedNickname.isEmpty || trimmedNickname.length > 20) {
      return const Result.failure('닉네임은 1자 이상 20자 이하로 입력해주세요.');
    }

    String? uploadedStoragePath;
    var profileImageUrl = currentUser.avatarUrl;

    if (profileImage != null) {
      final uploadResult = await _profileRepository.uploadProfileImage(
        accountId: currentUser.id,
        file: profileImage,
      );

      switch (uploadResult) {
        case Success(data: final image):
          uploadedStoragePath = image.storagePath;
          profileImageUrl = image.publicUrl;
        case Failure(message: final message):
          return Result.failure(message);
      }
    }

    final updateResult = await _profileRepository.updateProfile(
      accountId: currentUser.id,
      nickname: trimmedNickname,
      profileImageUrl: profileImageUrl,
    );

    switch (updateResult) {
      case Success(data: final profile):
        if (uploadedStoragePath != null) {
          final oldStoragePath = _profileStoragePath(currentUser.avatarUrl);
          if (oldStoragePath != null && oldStoragePath != uploadedStoragePath) {
            await _storageCleanupRepository.enqueue(
              bucketName: StorageBucket.profileImages,
              storagePaths: [oldStoragePath],
            );
          }
        }

        final updatedUser = _userFromProfile(
          currentUser.copyWith(nickname: profile.nickname),
          profile,
        );
        _currentUser = updatedUser;
        return Result.success(updatedUser);
      case Failure(message: final message):
        if (uploadedStoragePath != null) {
          await _storageCleanupRepository.enqueue(
            bucketName: StorageBucket.profileImages,
            storagePaths: [uploadedStoragePath],
          );
        }
        return Result.failure(message);
    }
  }

  /// 프로필의 거주 지역을 저장한 뒤 현재 사용자 정보에 반영합니다.
  @override
  Future<Result<User>> updateRegion({
    required String upperRegion,
    required String lowerRegion,
  }) async {
    final currentUser = _currentUser;
    if (currentUser == null) {
      return const Result.failure('로그인 후 거주 지역을 수정할 수 있습니다.');
    }

    final result = await _profileRepository.updateRegion(
      accountId: currentUser.id,
      upperRegion: upperRegion,
      lowerRegion: lowerRegion,
    );

    return switch (result) {
      Success(data: final profile) => _updateCurrentUser(profile),
      Failure(message: final message) => Result.failure(message),
    };
  }

  /// 서버에서 최신 프로필을 조회한 뒤 현재 사용자 정보에 반영합니다.
  @override
  Future<Result<User>> refreshCurrentUser() async {
    final currentUser = _currentUser;
    if (currentUser == null) {
      return const Result.failure('로그인 후 프로필을 새로고침할 수 있습니다.');
    }

    final result = await _profileRepository.getProfile(
      accountId: currentUser.id,
    );

    return switch (result) {
      Success(data: final profile) => _updateCurrentUser(profile),
      Failure(message: final message) => Result.failure(message),
    };
  }

  @override
  User? get currentUser => _currentUser;

  @override
  bool get isSignedIn => _currentUser != null;

  /// 초기화·복원 오류·현재 사용자 유무를 조합해 앱에 노출할 인증 상태를 계산합니다.
  @override
  AuthSessionStatus get sessionStatus {
    if (!_isInitialized) return AuthSessionStatus.initializing;
    if (_sessionErrorMessage != null) return AuthSessionStatus.error;
    return isSignedIn
        ? AuthSessionStatus.signedIn
        : AuthSessionStatus.signedOut;
  }

  /// 초기 세션 복원이 끝난 뒤 현재 상태와 이후 상태 변경을 순서대로 방출합니다.
  Stream<AuthSessionStatus> _watchAuthState() async* {
    await _restoreFuture;
    yield sessionStatus;
    yield* _authStateController.stream;
  }

  /// 저장된 인증 식별자로 앱 사용자를 복원하고 복원 실패 상태를 기록합니다.
  Future<void> _restoreSession() async {
    final result = await _dataSource.restoreSession();

    switch (result) {
      case Success(data: final identity):
        if (identity == null) {
          _currentUser = null;
          _sessionErrorMessage = null;
        } else {
          final userResult = await _loadUser(identity);
          switch (userResult) {
            case Success(data: final user):
              _currentUser = user;
              _sessionErrorMessage = null;
            case Failure(message: final message):
              _currentUser = null;
              _sessionErrorMessage = message;
          }
        }
      case Failure(message: final message):
        _currentUser = null;
        _sessionErrorMessage = message;
    }

    _isInitialized = true;
    _authStateController.add(sessionStatus);
  }

  /// 인증 식별자에서 프로필을 불러와 현재 앱 사용자로 설정하고 signed-in 상태를 알립니다.
  Future<Result<bool>> _completeSignIn(AuthIdentity identity) async {
    final userResult = await _loadUser(identity);

    switch (userResult) {
      case Success(data: final user):
        _currentUser = user;
        _sessionErrorMessage = null;
        _isInitialized = true;
        _authStateController.add(AuthSessionStatus.signedIn);
        return const Result.success(true);
      case Failure(message: final message):
        return Result.failure(message);
    }
  }

  /// 인증 식별자와 Supabase 프로필을 결합해 앱에서 사용하는 사용자 모델을 만듭니다.
  Future<Result<User>> _loadUser(AuthIdentity identity) async {
    final profileResult = await _profileRepository.getProfile(
      accountId: identity.accountId,
    );

    return switch (profileResult) {
      Success(data: final profile) => Result.success(
        User(
          id: identity.accountId,
          nickname: profile.nickname,
          email: identity.email,
          avatarUrl: profile.profileImageUrl ?? identity.avatarUrl,
          authProvider: identity.authProvider,
          upperRegion: profile.upperRegion,
          lowerRegion: profile.lowerRegion,
        ),
      ),
      Failure(message: final message) => Result.failure(message),
    };
  }

  /// 저장된 프로필을 현재 사용자 모델에 반영하고 갱신된 사용자를 반환합니다.
  Result<User> _updateCurrentUser(Profile profile) {
    final currentUser = _currentUser;
    if (currentUser == null) {
      return const Result.failure('로그인 후 프로필을 수정할 수 있습니다.');
    }

    final updatedUser = _userFromProfile(currentUser, profile);
    _currentUser = updatedUser;
    return Result.success(updatedUser);
  }

  /// 프로필 변경 결과를 기존 사용자 정보와 결합해 새로운 사용자 모델을 만듭니다.
  User _userFromProfile(User user, Profile profile) {
    return user.copyWith(
      nickname: profile.nickname,
      avatarUrl: profile.profileImageUrl ?? user.avatarUrl,
      upperRegion: profile.upperRegion,
      lowerRegion: profile.lowerRegion,
    );
  }

  /// 공개 프로필 이미지 URL에서 Storage 정리 큐에 사용할 경로를 추출합니다.
  String? _profileStoragePath(String? publicUrl) {
    if (publicUrl == null) return null;

    final marker = '/storage/v1/object/public/profile-images/';
    final markerIndex = publicUrl.indexOf(marker);
    if (markerIndex == -1) return null;

    return Uri.decodeComponent(
      publicUrl.substring(markerIndex + marker.length),
    );
  }

  /// 인증 상태 스트림을 닫아 Repository가 해제될 때 리소스를 정리합니다.
  void dispose() {
    _authStateController.close();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((Ref ref) {
  final repository = AuthRepositoryImpl(
    dataSource: ref.watch(authDataSourceProvider),
    profileRepository: ref.watch(profileRepositoryProvider),
    storageCleanupRepository: ref.watch(storageCleanupRepositoryProvider),
  );
  ref.onDispose(repository.dispose);
  return repository;
});
