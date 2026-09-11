import 'dart:convert';

import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:meomum/core/auth/auth0_config.dart';

class Auth0Session {
  static const int _tokenRefreshWindowSeconds = 60;

  static final client = Auth0(Auth0Config.domain, Auth0Config.clientId);

  static Future<String?> idToken() async {
    try {
      if (!await client.credentialsManager.hasValidCredentials(
        minTtl: _tokenRefreshWindowSeconds,
      )) {
        return null;
      }

      final credentials = await client.credentialsManager.credentials(
        minTtl: _tokenRefreshWindowSeconds,
      );

      if (_isExpired(credentials.idToken)) {
        return (await client.credentialsManager.renewCredentials()).idToken;
      }

      return credentials.idToken;
    } catch (_) {
      return null;
    }
  }

  static bool _isExpired(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return true;

    try {
      final normalizedPayload = base64Url.normalize(parts[1]);
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(normalizedPayload)),
      );
      if (payload is! Map<String, dynamic>) return true;

      final expiration = payload['exp'];
      if (expiration is! num) return true;

      return DateTime.now().millisecondsSinceEpoch >= expiration * 1000;
    } catch (_) {
      return true;
    }
  }
}
