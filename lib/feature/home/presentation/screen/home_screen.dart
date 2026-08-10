import 'package:flutter/material.dart';
import 'package:meomum/core/domain/enum/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatelessWidget {
  final User? user;

  const HomeScreen({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('로그인된 사용자가 없습니다.'),
        ),
      );
    }

    final currentUser = user!;
    final providerLabel = _resolveProviderLabel(currentUser);
    final displayName =
        currentUser.userMetadata?['full_name'] as String? ??
        currentUser.userMetadata?['name'] as String? ??
        '-';
    final avatarUrl =
        currentUser.userMetadata?['avatar_url'] as String? ??
        currentUser.userMetadata?['picture'] as String? ??
        '-';

    return Scaffold(
      appBar: AppBar(title: const Text('홈')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('인증 제공자: $providerLabel'),
              const SizedBox(height: 12),
              Text('id: ${currentUser.id}'),
              const SizedBox(height: 8),
              Text('email: ${currentUser.email ?? '-'}'),
              const SizedBox(height: 8),
              Text('displayName: $displayName'),
              const SizedBox(height: 8),
              Text('avatarUrl: $avatarUrl'),
            ],
          ),
        ),
      ),
    );
  }

  String _resolveProviderLabel(User user) {
    final identityProvider = user.identities?.isNotEmpty == true
        ? user.identities!.first.provider
        : null;
    final appProvider = user.appMetadata['provider'] as String?;
    final rawProvider = identityProvider ?? appProvider;

    if (rawProvider == null) {
      return '알 수 없음';
    }

    return switch (rawProvider) {
      'google' => AuthProvider.google.toDisplayName(),
      'kakao' => AuthProvider.kakao.toDisplayName(),
      'naver' => AuthProvider.naver.toDisplayName(),
      _ => rawProvider,
    };
  }
}
