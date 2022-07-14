import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../auth_providers.dart';

class TokenProvider {
  final _accessTokenKey = 'ACCESS_TOKEN';
  final _refreshTokenKey = 'REFRESH_TOKEN';
  final _storage = const FlutterSecureStorage();
  bool _init = false;
  Token? _token;

  Future<Token?> read() async {
    if (!_init) {
      _init = true;
      final accessToken = await _storage.read(key: _accessTokenKey);
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      if (accessToken != null && refreshToken != null) {
        _token = Token(accessToken: accessToken, refreshToken: refreshToken);
      }
    }
    return _token;
  }

  Future<void> write(Token token) async {
    _token = token;
    await _storage.write(key: _accessTokenKey, value: token.accessToken);
    await _storage.write(key: _refreshTokenKey, value: token.refreshToken);
  }

  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
