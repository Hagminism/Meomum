import 'package:meomum/core/domain/enum/auth_provider.dart';
import 'package:meomum/core/domain/model/user/auth_identity.dart';
import 'package:meomum/core/utils/result.dart';

abstract interface class AuthDataSource {
  Future<Result<AuthIdentity>> signInWithOAuth(AuthProvider provider);

  Future<Result<AuthIdentity?>> restoreSession();

  Future<Result<bool>> signOut();
}
