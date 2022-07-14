import 'package:dio/dio.dart';

import '../auth_providers.dart';

class AuthProvider {
  final Dio _dio;

  AuthProvider(this._dio);

  Future<void> register({
    required String username,
    required String password,
  }) async {
    await _dio.post(
      '/auth/register',
      data: {
        'username': username,
        'password': password,
      },
    );
  }

  Future<Token> login({
    required String username,
    required String password,
  }) async {
    final res = await _dio.post(
      '/auth/login',
      data: {
        'username': username,
        'password': password,
      },
    );
    return Token.fromJson(res.data);
  }

  Future<void> logout() async {
    await _dio.post('/auth/logout');
  }
}
