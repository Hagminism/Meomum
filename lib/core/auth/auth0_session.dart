import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:meomum/core/auth/auth0_config.dart';

class Auth0Session {
  static final client = Auth0(Auth0Config.domain, Auth0Config.clientId);

  static Future<String?> idToken() async {
    try {
      if (!await client.credentialsManager.hasValidCredentials()) {
        return null;
      }
      return (await client.credentialsManager.credentials()).idToken;
    } catch (_) {
      return null;
    }
  }
}
