import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meomum/core/domain/enum/auth_provider.dart';

part 'user.freezed.dart';

@freezed
abstract class User with _$User {
  const User._();

  const factory User({
    required String id,
    required String nickname,
    String? email,
    String? avatarUrl,
    AuthProvider? authProvider,
    String? upperRegion,
    String? lowerRegion,
  }) = _User;

  bool get hasSelectedRegion {
    return upperRegion != null && lowerRegion != null;
  }

  bool get hasPartialRegion {
    return (upperRegion == null) != (lowerRegion == null);
  }
}
