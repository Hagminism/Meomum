import 'package:meomum/core/domain/enum/auth_provider.dart';
import 'package:meomum/core/domain/enum/auth_session_status.dart';
import 'package:meomum/core/utils/result.dart';

abstract interface class AuthDataSource {
  Future<Result<bool>> signInWithOAuth(AuthProvider provider);

  Future<Result<bool>> signOut();

  Stream<AuthSessionStatus> watchAuthState();

  bool get isSignedIn;
}
