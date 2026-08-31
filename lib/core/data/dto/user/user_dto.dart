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
    final provider = _extractAuthProvider(user);
    authProvider = provider;
    nickname = _extractNickname(user, provider);
    avatarUrl = _extractAvatarUrl(user, provider);
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

  String? _extractNickname(supabase.User user, String? provider) {
    final metadata = user.userMetadata ?? {};

    // Provider별 우선순위 지정
    final List<String> searchKeys = switch (provider) {
      'kakao' => ['nickname', 'name', 'full_name', 'user_name'],
      'naver' || 'custom:naver' => ['name', 'nickname', 'full_name', 'user_name'],
      _ => ['full_name', 'name', 'nickname', 'user_name'],
    };

    for (final key in searchKeys) {
      final value = metadata[key];
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }

    return null;
  }

  String? _extractAvatarUrl(supabase.User user, String? provider) {
    final metadata = user.userMetadata ?? {};

    // Provider별 우선순위 지정
    final List<String> searchKeys = switch (provider) {
      'kakao' => ['avatar_url', 'profile_image', 'picture'],
      'naver' || 'custom:naver' => ['picture', 'profile_image', 'avatar_url'],
      _ => ['picture', 'avatar_url', 'profile_image'],
    };

    for (final key in searchKeys) {
      final value = metadata[key];
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }

    return null;
  }
}
