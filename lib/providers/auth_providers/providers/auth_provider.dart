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

  Future<LoginResponse> login({
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
    return LoginResponse.fromJson(res.data);
  }

  Future<void> logout() async {
    await _dio.post('/auth/logout');
  }

  Future<void> sendCode() async {
    await _dio.post('/verification/send-code');
  }

  Future<void> verifyCode(String code) async {
    await _dio.post('/verification/verify-code', data: {
      'code': code,
    });
  }

  Future<bool> isVerified() async {
    final res = await _dio.get('/verification/is-verified');
    return res.data;
  }
}
