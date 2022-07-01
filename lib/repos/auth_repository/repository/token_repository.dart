import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:talk/repos/repos.dart';

class TokenRepository {
  final _accessTokenKey = 'ACCESS_TOKEN';
  final _refreshTokenKey = 'REFRESH_TOKEN';
  final _storage = const FlutterSecureStorage();

  Future<String?> get accessToken => _storage.read(key: _accessTokenKey);
  Future<String?> get refreshToken => _storage.read(key: _refreshTokenKey);

  Future<Token?> get token async {
    final a = await accessToken;
    final r = await refreshToken;
    if (a == null || r == null) return null;
    return Token(
      accessToken: a,
      refreshToken: r,
    );
  }

  Future<void> setToken(Token token) async {
    setAccessToken(token.accessToken);
    setRefreshToken(token.refreshToken);
  }

  Future<void> setAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  Future<void> setRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
