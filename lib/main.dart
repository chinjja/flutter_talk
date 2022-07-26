import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:talk/repos/repos.dart';

import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080'));
  final authProvider = AuthProvider(dio);
  final tokenProvider = TokenProvider();
  final userProvider = UserProvider(dio);
  final authRepository = AuthRepository(
    authProvider,
    tokenProvider,
  );
  final userRepository = UserRepository(userProvider);

  final chatProvider = ChatProvider(dio);
  final chatUserProvider = ChatUserProvider(dio);
  final chatMessageProvider = ChatMessageProvider(dio);
  final chatListenProvider = ChatListenProvider(dio, chatProvider);
  final friendProvider = FriendProvider(dio);
  final chatRepository = ChatRepository(
    authRepository,
    chatProvider,
    chatUserProvider,
    chatMessageProvider,
    friendProvider,
    chatListenProvider,
  );

  Future<bool> _refresh() async {
    final token = await tokenProvider.read();
    if (token != null) {
      final refreshDio = Dio(BaseOptions(baseUrl: dio.options.baseUrl));
      try {
        final res = await refreshDio.post(
          '/auth/refresh',
          data: token.toJson(),
        );
        await tokenProvider
            .write(token.copyWith(accessToken: res.data['accessToken']));
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
      final token = await tokenProvider.read();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer ${token.accessToken}';
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

  await authRepository.init();

  runApp(
    App(
      userRepository: userRepository,
      authRepository: authRepository,
      chatRepository: chatRepository,
    ),
  );
}
