import 'dart:async';
import 'dart:io';

import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/core/auth/auth0_session.dart';
import 'package:meomum/core/data/data_source/auth/auth_data_source.dart';
import 'package:meomum/core/domain/enum/auth_provider.dart';
import 'package:meomum/core/domain/enum/auth_session_status.dart';
import 'package:meomum/core/domain/model/user/user.dart';
import 'package:meomum/core/utils/result.dart';
import 'package:meomum/di/di.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

/// Auth0 세션을 복원하고, Auth0 사용자와 앱의 accounts 레코드를 연결한다.
///
/// 로그인 토큰의 보관과 갱신은 Auth0 CredentialsManager에 맡기고,
/// Supabase는 인증된 토큰으로 앱 데이터와 accounts를 관리한다.
class AuthDataSourceImpl implements AuthDataSource {
  final SupabaseClient _client;
  final Auth0 _auth0;

  AuthDataSourceImpl({
    required this._client,
    required this._auth0,
  }) {
    _restoreFuture = _restoreSession();
  }

  late final Future<void> _restoreFuture;
  final _authStateController = StreamController<AuthSessionStatus>.broadcast();
  User? _currentUser;
  bool _isInitialized = false;

  /// 현재 인증된 앱 사용자의 프로필이다. 로그인 전이거나 복원에 실패하면 `null`이다.
  @override
  User? get currentUser => _currentUser;

  /// 앱이 사용할 수 있는 인증된 사용자가 있는지 반환한다.
  @override
  bool get isSignedIn => _currentUser != null;

  /// 자격 증명 복원 중에는 initializing을, 완료 후에는 실제 로그인 상태를 반환한다.
  @override
  AuthSessionStatus get sessionStatus {
    if (!_isInitialized) return AuthSessionStatus.initializing;
    return isSignedIn
        ? AuthSessionStatus.signedIn
        : AuthSessionStatus.signedOut;
  }

  /// 선택한 Auth0 Connection으로 Universal Login을 진행하고 앱 계정을 준비한다.
  ///
  /// Android에서는 HTTPS App Link, iOS에서는 Custom URL Scheme으로 앱으로 돌아온다.
  @override
  Future<Result<bool>> signInWithOAuth(AuthProvider provider) async {
    try {
      // TODO: 릴리즈 시 iOS에서도 Univerial Link 방식으로 수정
      final credentials = await _auth0.webAuthentication().login(
        useHTTPS: !Platform.isIOS,
        parameters: {'connection': _connectionName(provider)},
      );
      await _setAuthenticatedUser(credentials, provider: provider);
      _authStateController.add(AuthSessionStatus.signedIn);
      return const Result.success(true);
    } on WebAuthenticationException catch (error) {
      return Result.failure(error.message);
    } on PostgrestException catch (error) {
      return Result.failure('계정을 준비하지 못했습니다: ${error.message}');
    } catch (error) {
      return Result.failure(error.toString());
    }
  }

  /// Auth0 브라우저 세션과 기기에 저장된 자격 증명을 모두 종료·삭제한다.
  @override
  Future<Result<bool>> signOut() async {
    try {
      await _auth0.webAuthentication().logout(useHTTPS: !Platform.isIOS);
      await _auth0.credentialsManager.clearCredentials();
      _currentUser = null;
      _authStateController.add(AuthSessionStatus.signedOut);
      return const Result.success(true);
    } on WebAuthenticationException catch (error) {
      return Result.failure(error.message);
    } catch (error) {
      return Result.failure(error.toString());
    }
  }

  /// 저장된 세션을 복원한 뒤 현재 인증 상태를 한 번 전달한다.
  /// 이후 [_authStateController]의 스트림을 구독하여 인증 상태 변경을 전달하며,
  /// 해당 스트림이 종료되면 이 스트림도 종료된다.
  @override
  Stream<AuthSessionStatus> watchAuthState() async* {
    await _restoreFuture;
    yield isSignedIn ? AuthSessionStatus.signedIn : AuthSessionStatus.signedOut;
    yield* _authStateController.stream;
  }

  /// Keychain/Keystore의 Auth0 자격 증명을 복원하고 앱 계정으로 변환한다.
  ///
  /// CredentialsManager는 필요할 경우 저장된 refresh token으로 자격 증명을 갱신한다.
  Future<void> _restoreSession() async {
    try {
      if (!await _auth0.credentialsManager.hasValidCredentials()) return;
      await _setAuthenticatedUser(
        await _auth0.credentialsManager.credentials(),
      );
    } catch (_) {
      _currentUser = null;
    } finally {
      _isInitialized = true;
    }
  }

  /// Auth0 사용자 정보를 Supabase accounts 레코드와 연결해 앱 사용자 모델을 만든다.
  ///
  /// `ensure_account` RPC는 Auth0 JWT의 subject를 이용해 계정을 생성하거나 찾는다.
  Future<void> _setAuthenticatedUser(
    Credentials credentials, {
    AuthProvider? provider,
  }) async {
    final accountId = await _client.rpc('ensure_account') as String;
    final profile = credentials.user;
    _currentUser = User(
      id: accountId,
      nickname: profile.name ?? profile.nickname ?? profile.email ?? '사용자',
      email: profile.email,
      avatarUrl: profile.pictureUrl?.toString(),
      authProvider: provider,
    );
  }

  /// 앱의 로그인 공급자 enum을 Auth0 Dashboard에 등록한 Connection 이름으로 변환한다.
  String _connectionName(AuthProvider provider) {
    return switch (provider) {
      AuthProvider.google => 'google-oauth2',
      AuthProvider.kakao => 'Kakao',
      AuthProvider.naver => 'Naver',
    };
  }

  /// 인증 상태 스트림을 닫는다.
  void dispose() {
    _authStateController.close();
  }
}

final authDataSourceProvider = Provider<AuthDataSource>((Ref ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  final dataSource = AuthDataSourceImpl(
    client: supabaseClient,
    auth0: Auth0Session.client,
  );
  // Riverpod provider가 폐기될 때 상태 스트림도 닫아 리소스 누수를 막는다.
  ref.onDispose(dataSource.dispose);
  return dataSource;
});
