import 'dart:io';

import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/core/auth/auth0_session.dart';
import 'package:meomum/core/data/data_source/auth/auth_data_source.dart';
import 'package:meomum/core/domain/enum/auth_provider.dart';
import 'package:meomum/core/domain/model/user/auth_identity.dart';
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
  });

  /// 선택한 Auth0 Connection으로 Universal Login을 진행하고 앱 계정을 준비한다.
  ///
  /// Android에서는 HTTPS App Link, iOS에서는 Custom URL Scheme으로 앱으로 돌아온다.
  @override
  Future<Result<AuthIdentity>> signInWithOAuth(AuthProvider provider) async {
    try {
      // TODO: 릴리즈 시 iOS에서도 Univerial Link 방식으로 수정
      final credentials = await _auth0.webAuthentication().login(
        useHTTPS: !Platform.isIOS,
        parameters: {'connection': _connectionName(provider)},
      );
      return Result.success(
        await _createAuthIdentity(credentials, provider: provider),
      );
    } on WebAuthenticationException catch (error) {
      return Result.failure(error.message);
    } on PostgrestException catch (error) {
      return Result.failure('계정을 준비하지 못했습니다: ${error.message}');
    } catch (error) {
      return Result.failure(error.toString());
    }
  }

  @override
  Future<Result<AuthIdentity?>> restoreSession() async {
    try {
      final hasValidCredentials = await _auth0.credentialsManager
          .hasValidCredentials(minTtl: 60);
      if (!hasValidCredentials) {
        return const Result.success(null);
      }

      final credentials = await _auth0.credentialsManager.credentials(
        minTtl: 60,
      );
      return Result.success(await _createAuthIdentity(credentials));
    } on CredentialsManagerException {
      // 만료되었거나 복원할 수 없는 인증 자격 증명은 재로그인으로 처리한다.
      return const Result.success(null);
    } catch (_) {
      return const Result.failure('인증 상태를 복원하지 못했습니다. 다시 시도해주세요.');
    }
  }

  /// Auth0 브라우저 세션과 기기에 저장된 자격 증명을 모두 종료·삭제한다.
  @override
  Future<Result<bool>> signOut() async {
    try {
      await _auth0.webAuthentication().logout(useHTTPS: !Platform.isIOS);
      await _auth0.credentialsManager.clearCredentials();
      return const Result.success(true);
    } on WebAuthenticationException catch (error) {
      return Result.failure(error.message);
    } catch (error) {
      return Result.failure(error.toString());
    }
  }

  /// Auth0 사용자 정보를 Supabase accounts 레코드와 연결해 인증 식별자를 만든다.
  ///
  /// `ensure_account` RPC는 Auth0 JWT의 subject를 이용해 계정을 생성하거나 찾는다.
  Future<AuthIdentity> _createAuthIdentity(
    Credentials credentials, {
    AuthProvider? provider,
  }) async {
    final accountId = await _client.rpc('ensure_account') as String;
    final auth0User = credentials.user;
    return AuthIdentity(
      accountId: accountId,
      email: auth0User.email,
      avatarUrl: auth0User.pictureUrl?.toString(),
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
}

final authDataSourceProvider = Provider<AuthDataSource>((Ref ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return AuthDataSourceImpl(
    client: supabaseClient,
    auth0: Auth0Session.client,
  );
});
