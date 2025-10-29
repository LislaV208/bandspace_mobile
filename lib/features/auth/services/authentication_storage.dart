import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:bandspace_mobile/features/auth/models/authentication_tokens.dart';

class AuthenticationStorage {
  final _storage = FlutterSecureStorage();

  static const _accessTokenKey = 'accessToken';
  static const _refreshTokenKey = 'refreshToken';

  Future<void> saveTokens(AuthenticationTokens tokens) async {
    await _storage.write(
      key: _accessTokenKey,
      value: tokens.accessToken,
    );

    await _storage.write(
      key: _refreshTokenKey,
      value: tokens.refreshToken,
    );
  }

  Future<AuthenticationTokens?> getTokens() async {
    final accessToken = await _storage.read(key: _accessTokenKey);
    final refreshToken = await _storage.read(key: _refreshTokenKey);

    if (accessToken == null || refreshToken == null) {
      return null;
    }

    return AuthenticationTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
