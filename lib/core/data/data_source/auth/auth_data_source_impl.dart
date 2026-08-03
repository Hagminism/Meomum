import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meomum/core/data/data_source/auth/auth_data_source.dart';
import 'package:meomum/core/domain/enum/auth_provider.dart';
import 'package:meomum/core/domain/enum/auth_session_status.dart';
import 'package:meomum/core/utils/auth_constants.dart';
import 'package:meomum/core/utils/result.dart';
import 'package:meomum/di/di.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthDataSourceImpl implements AuthDataSource {
  final GoTrueClient _auth;
  final GoogleSignIn _googleSignIn;

  AuthDataSourceImpl({
    required this._auth,
    required this._googleSignIn,
  });

  @override
  Future<Result<bool>> signInWithOAuth(AuthProvider provider) async {
    return switch (provider) {
      AuthProvider.google => _signInWithGoogle(),
      AuthProvider.kakao => _signInWithOAuthBrowser(OAuthProvider.kakao),
      AuthProvider.apple => const Result.failure(
        '애플 로그인은 추후 지원 예정입니다.',
      ),
      AuthProvider.naver => const Result.failure(
        '네이버 로그인은 추후 지원 예정입니다.',
      ),
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
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      return const Result.success(true);
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        return Result.failure(error.toString());
      }
      return Result.failure(error.description ?? error.toString());
    } on AuthException catch (error) {
      return Result.failure(error.message);
    } catch (error) {
      return Result.failure(error.toString());
    }
  }

  Future<Result<bool>> _signInWithOAuthBrowser(OAuthProvider provider) async {
    try {
      final launched = await _auth.signInWithOAuth(
        provider,
        redirectTo: AuthConstants.redirectUrl,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      if (!launched) {
        return const Result.failure('OAuth 화면을 열지 못했습니다.');
      }

      return const Result.success(true);
    } on AuthException catch (error) {
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
    } on AuthException catch (error) {
      return Result.failure(error.message);
    } catch (error) {
      return Result.failure(error.toString());
    }
  }

  @override
  Stream<AuthSessionStatus> watchAuthState() {
    return _auth.onAuthStateChange.map((AuthState data) {
      final session = data.session;
      if (session != null) {
        return AuthSessionStatus.signedIn;
      }
      return AuthSessionStatus.signedOut;
    });
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
