import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/core/data/data_source/auth/auth_data_source.dart';
import 'package:meomum/core/data/data_source/auth/auth_data_source_impl.dart';
import 'package:meomum/core/domain/enum/auth_provider.dart';
import 'package:meomum/core/domain/enum/auth_session_status.dart';
import 'package:meomum/core/domain/repository/auth/auth_repository.dart';
import 'package:meomum/core/utils/result.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _dataSource;

  AuthRepositoryImpl({
    required AuthDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<Result<bool>> signInWithOAuth(AuthProvider provider) {
    return _dataSource.signInWithOAuth(provider);
  }

  @override
  Future<Result<bool>> signOut() {
    return _dataSource.signOut();
  }

  @override
  Stream<AuthSessionStatus> watchAuthState() {
    return _dataSource.watchAuthState();
  }

  @override
  bool get isSignedIn => _dataSource.isSignedIn;
}

final authRepositoryProvider = Provider<AuthRepository>((Ref ref) {
  return AuthRepositoryImpl(
    dataSource: ref.watch(authDataSourceProvider),
  );
});
