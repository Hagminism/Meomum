import 'package:meomum/core/data/dto/user/user_dto.dart';
import 'package:meomum/core/domain/enum/auth_provider.dart';
import 'package:meomum/core/domain/model/user/user.dart';

extension UserDtoMapper on UserDto {
  User toModel() {
    return User(
      id: id ?? '',
      nickname: _resolveNickname(),
      email: email,
      avatarUrl: avatarUrl,
      authProvider: _parseAuthProvider(authProvider),
    );
  }

  String _resolveNickname() {
    if (nickname != null && nickname!.isNotEmpty) {
      return nickname!;
    }

    final userEmail = email;
    if (userEmail != null && userEmail.contains('@')) {
      return userEmail.split('@').first;
    }

    return '사용자';
  }

  AuthProvider? _parseAuthProvider(String? provider) {
    return switch (provider) {
      'google' => AuthProvider.google,
      'kakao' => AuthProvider.kakao,
      'naver' || 'custom:naver' => AuthProvider.naver,
      _ => null,
    };
  }
}
