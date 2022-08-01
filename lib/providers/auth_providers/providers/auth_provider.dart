import 'dart:convert';

import '../../providers.dart';

class AuthProvider {
  final ApiClient _client;

  AuthProvider(this._client);

  Future<void> register({
    required String username,
    required String password,
  }) async {
    await _client.post(
      _client.uri('/auth/register'),
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );
  }

  Future<Token> login({
    required String username,
    required String password,
  }) async {
    final res = await _client.post(
      _client.uri('/auth/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );
    final json = jsonDecode(res.body);
    return Token.fromJson(json);
  }

  Future<void> logout() async {
    await _client.post(
      _client.uri('/auth/logout'),
    );
  }

  Future<void> sendCode() async {
    await _client.post(
      _client.uri('/verification/send-code'),
    );
  }

  Future<void> verifyCode(String code) async {
    await _client.post(
      _client.uri('/verification/verify-code'),
      body: jsonEncode({
        'code': code,
      }),
    );
  }

  Future<bool> isVerified() async {
    final res = await _client.get(
      _client.uri('/verification/is-verified'),
    );

    final json = jsonDecode(res.body);
    return json;
  }

  Future<void> sendResetPassword(String email) async {
    await _client.post(
      _client.uri('/auth/reset/$email'),
    );
  }
}
