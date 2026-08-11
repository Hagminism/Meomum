import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class UserDto {
  String? id;
  String? email;
  String? authProvider;
  String? nickname;
  String? avatarUrl;

  UserDto({
    this.id,
    this.email,
    this.authProvider,
    this.nickname,
    this.avatarUrl,
  });

  UserDto.fromJson(dynamic json) {
    id = json['id'];
    email = json['email'];
    authProvider = json['auth_provider'];
    nickname = json['nickname'];
    avatarUrl = json['avatar_url'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['email'] = email;
    map['auth_provider'] = authProvider;
    map['nickname'] = nickname;
    map['avatar_url'] = avatarUrl;
    return map;
  }

  UserDto.fromSupabaseUser(supabase.User user) {
    id = user.id;
    email = user.email;
    authProvider = _extractAuthProvider(user);
    nickname = _extractNickname(user);
    avatarUrl = _extractAvatarUrl(user);
  }

  String? _extractAuthProvider(supabase.User user) {
    final provider = user.appMetadata['provider'] as String?;
    if (provider != null) {
      return provider;
    }

    final identities = user.identities;
    if (identities != null && identities.isNotEmpty) {
      return identities.first.provider;
    }

    return null;
  }

  String? _extractNickname(supabase.User user) {
    final metadata = user.userMetadata ?? {};

    for (final key in ['full_name', 'name', 'nickname', 'user_name']) {
      final value = metadata[key];
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }

    return null;
  }

  String? _extractAvatarUrl(supabase.User user) {
    final metadata = user.userMetadata ?? {};

    for (final key in ['avatar_url', 'picture', 'profile_image']) {
      final value = metadata[key];
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }

    return null;
  }
}
