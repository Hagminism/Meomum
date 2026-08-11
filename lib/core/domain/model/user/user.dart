import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meomum/core/domain/enum/auth_provider.dart';

part 'user.freezed.dart';

@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String nickname,
    String? email,
    String? avatarUrl,
    AuthProvider? authProvider,
  }) = _User;
}
