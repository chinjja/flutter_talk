import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:talk/repos/repos.dart';

import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final tokenRepository = TokenRepository();
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080'));
  final authRepository = AuthRepository(
    dio: dio,
    tokenRepository: tokenRepository,
  );
  final chatRepository = ChatRepository(
    dio: dio,
    authRepository: authRepository,
  );
  await authRepository.init();

  Future<bool> _refresh() async {
    final token = await tokenRepository.token;
    if (token != null) {
      final refreshDio = Dio(BaseOptions(baseUrl: dio.options.baseUrl));
      try {
        final res = await refreshDio.post(
          '/auth/refresh',
          data: token.toJson(),
        );
        await tokenRepository.setAccessToken(res.data['accessToken']);
        return true;
      } on DioError catch (e) {
        if (e.response?.statusCode == HttpStatus.unauthorized) {
          authRepository.logout();
        }
      }
    }
    return false;
  }

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final accessToken = await tokenRepository.accessToken;
      if (accessToken != null) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
      handler.next(options);
    },
    onError: (error, handler) async {
      if (error.response?.statusCode == HttpStatus.unauthorized) {
        if (await _refresh()) {
          final response = await dio.request(
            error.requestOptions.path,
            options: Options(
              method: error.requestOptions.method,
              headers: error.requestOptions.headers,
            ),
            data: error.requestOptions.data,
            queryParameters: error.requestOptions.queryParameters,
          );
          return handler.resolve(response);
        }
      }
      return handler.next(error);
    },
  ));
  runApp(
    App(
      tokenRepository: tokenRepository,
      authRepository: authRepository,
      chatRepository: chatRepository,
    ),
  );
}
