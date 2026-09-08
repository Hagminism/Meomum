import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/core/data/data_source/auth/auth_data_source.dart';
import 'package:meomum/core/data/data_source/auth/auth_data_source_impl.dart';
import 'package:meomum/core/data/repository/profile/profile_repository_impl.dart';
import 'package:meomum/core/domain/enum/auth_provider.dart';
import 'package:meomum/core/domain/enum/auth_session_status.dart';
import 'package:meomum/core/domain/model/user/auth_identity.dart';
import 'package:meomum/core/domain/model/user/profile.dart';
import 'package:meomum/core/domain/model/user/user.dart';
import 'package:meomum/core/domain/repository/auth/auth_repository.dart';
import 'package:meomum/core/domain/repository/profile/profile_repository.dart';
import 'package:meomum/core/utils/result.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _dataSource;
  final ProfileRepository _profileRepository;

  late final Future<void> _restoreFuture;
  final StreamController<AuthSessionStatus> _authStateController =
      StreamController<AuthSessionStatus>.broadcast();
  User? _currentUser;
  bool _isInitialized = false;
  String? _sessionErrorMessage;

  AuthRepositoryImpl({
    required this._dataSource,
    required this._profileRepository,
  }) {
    _restoreFuture = _restoreSession();
  }

  @override
  Future<Result<bool>> signInWithOAuth(AuthProvider provider) async {
    final result = await _dataSource.signInWithOAuth(provider);

    return switch (result) {
      Success(data: final identity) => await _completeSignIn(identity),
      Failure(message: final message) => Result.failure(message),
    };
  }

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

  @override
  Stream<AuthSessionStatus> watchAuthState() {
    return _watchAuthState();
  }

  @override
  Future<void> retrySessionRestore() async {
    _isInitialized = false;
    _sessionErrorMessage = null;
    _authStateController.add(AuthSessionStatus.initializing);
    await _restoreSession();
  }

  @override
  String? get sessionErrorMessage => _sessionErrorMessage;

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
            await _profileRepository.deleteProfileImage(
              storagePath: oldStoragePath,
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
          await _profileRepository.deleteProfileImage(
            storagePath: uploadedStoragePath,
          );
        }
        return Result.failure(message);
    }
  }

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

  @override
  User? get currentUser => _currentUser;

  @override
  bool get isSignedIn => _currentUser != null;

  @override
  AuthSessionStatus get sessionStatus {
    if (!_isInitialized) return AuthSessionStatus.initializing;
    if (_sessionErrorMessage != null) return AuthSessionStatus.error;
    return isSignedIn
        ? AuthSessionStatus.signedIn
        : AuthSessionStatus.signedOut;
  }

  Stream<AuthSessionStatus> _watchAuthState() async* {
    await _restoreFuture;
    yield sessionStatus;
    yield* _authStateController.stream;
  }

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

  Result<User> _updateCurrentUser(Profile profile) {
    final currentUser = _currentUser;
    if (currentUser == null) {
      return const Result.failure('로그인 후 프로필을 수정할 수 있습니다.');
    }

    final updatedUser = _userFromProfile(currentUser, profile);
    _currentUser = updatedUser;
    return Result.success(updatedUser);
  }

  User _userFromProfile(User user, Profile profile) {
    return user.copyWith(
      nickname: profile.nickname,
      avatarUrl: profile.profileImageUrl ?? user.avatarUrl,
      upperRegion: profile.upperRegion,
      lowerRegion: profile.lowerRegion,
    );
  }

  String? _profileStoragePath(String? publicUrl) {
    if (publicUrl == null) return null;

    final marker = '/storage/v1/object/public/profile-images/';
    final markerIndex = publicUrl.indexOf(marker);
    if (markerIndex == -1) return null;

    return Uri.decodeComponent(
      publicUrl.substring(markerIndex + marker.length),
    );
  }

  void dispose() {
    _authStateController.close();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((Ref ref) {
  final repository = AuthRepositoryImpl(
    dataSource: ref.watch(authDataSourceProvider),
    profileRepository: ref.watch(profileRepositoryProvider),
  );
  ref.onDispose(repository.dispose);
  return repository;
});
