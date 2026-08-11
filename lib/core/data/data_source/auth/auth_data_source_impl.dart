import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meomum/core/data/data_source/auth/auth_data_source.dart';
import 'package:meomum/core/data/dto/user/user_dto.dart';
import 'package:meomum/core/data/mapper/user/user_mapper.dart';
import 'package:meomum/core/domain/enum/auth_provider.dart';
import 'package:meomum/core/domain/enum/auth_session_status.dart';
import 'package:meomum/core/domain/model/user/user.dart';
import 'package:meomum/core/utils/result.dart';
import 'package:meomum/di/di.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class AuthDataSourceImpl implements AuthDataSource {
  final supabase.GoTrueClient _auth;
  final GoogleSignIn _googleSignIn;

  static const String redirectUrl = 'meomum://login-callback';
  static const String naverOAuthProviderName = 'custom:naver';

  AuthDataSourceImpl({
    required this._auth,
    required this._googleSignIn,
  });

  @override
  Future<Result<bool>> signInWithOAuth(AuthProvider provider) async {
    return switch (provider) {
      AuthProvider.google => _signInWithGoogle(),
      AuthProvider.kakao => _signInWithKakao(),
      AuthProvider.naver => _signInWithNaver(),
    };
  }

  Future<Result<bool>> _signInWithGoogle() async {
    try {
      const scopes = ['email', 'profile'];

      final lightweightAccount = await _googleSignIn
          .attemptLightweightAuthentication();
      final googleAccount =
          lightweightAccount ?? await _googleSignIn.authenticate();

      final googleAuthorization =
          await googleAccount.authorizationClient.authorizationForScopes(
            scopes,
          ) ??
          await googleAccount.authorizationClient.authorizeScopes(scopes);
      final idToken = googleAccount.authentication.idToken;
      final accessToken = googleAuthorization.accessToken;

      if (idToken == null) {
        return const Result.failure('Google ID Token을 가져오지 못했습니다.');
      }

      await _auth.signInWithIdToken(
        provider: supabase.OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      return const Result.success(true);
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        return Result.failure(error.toString());
      }
      return Result.failure(error.description ?? error.toString());
    } on supabase.AuthException catch (error) {
      return Result.failure(error.message);
    } catch (error) {
      return Result.failure(error.toString());
    }
  }

  Future<Result<bool>> _signInWithKakao() async {
    return _signInWithOAuthProvider(supabase.OAuthProvider.kakao);
  }

  Future<Result<bool>> _signInWithNaver() async {
    return _signInWithOAuthProvider(
      supabase.OAuthProvider(naverOAuthProviderName),
    );
  }

  Future<Result<bool>> _signInWithOAuthProvider(
    supabase.OAuthProvider provider,
  ) async {
    try {
      await _auth.signInWithOAuth(
        provider,
        redirectTo: kIsWeb ? null : redirectUrl,
        authScreenLaunchMode: kIsWeb
            ? supabase.LaunchMode.platformDefault
            : supabase.LaunchMode.externalApplication,
      );

      return const Result.success(true);
    } on supabase.AuthException catch (error) {
      return Result.failure(error.message);
    } catch (error) {
      return Result.failure(error.toString());
    }
  }

  @override
  Future<Result<bool>> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      return const Result.success(true);
    } on supabase.AuthException catch (error) {
      return Result.failure(error.message);
    } catch (error) {
      return Result.failure(error.toString());
    }
  }

  @override
  Stream<AuthSessionStatus> watchAuthState() {
    return _auth.onAuthStateChange.map((supabase.AuthState data) {
      final session = data.session;
      if (session != null) {
        return AuthSessionStatus.signedIn;
      }
      return AuthSessionStatus.signedOut;
    });
  }

  @override
  User? get currentUser => _mapCurrentUser(_auth.currentUser);

  User? _mapCurrentUser(supabase.User? user) {
    if (user == null) return null;

    return UserDto.fromSupabaseUser(user).toModel();
  }

  @override
  bool get isSignedIn => _auth.currentSession != null;
}

final authDataSourceProvider = Provider<AuthDataSource>((Ref ref) {
  return AuthDataSourceImpl(
    auth: ref.watch(supabaseClientProvider).auth,
    googleSignIn: ref.watch(googleSignInProvider),
  );
});
