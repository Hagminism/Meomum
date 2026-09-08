import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meomum/core/domain/enum/auth_provider.dart';

part 'auth_identity.freezed.dart';

@freezed
abstract class AuthIdentity with _$AuthIdentity {
  const factory AuthIdentity({
    required String accountId,
    String? email,
    String? avatarUrl,
    AuthProvider? authProvider,
  }) = _AuthIdentity;
}
