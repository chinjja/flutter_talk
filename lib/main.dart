import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:talk/interceptors/interceptors.dart';
import 'package:talk/repos/repos.dart';

import 'app/app.dart';

late String storageUrl;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const baseUrl = String.fromEnvironment(
    'base-url',
    defaultValue: 'http://localhost:8080',
  );
  storageUrl = const String.fromEnvironment(
    'storage-url',
    defaultValue: 'http://localhost:8080/storage',
  );
  final dio = Dio(
    BaseOptions(baseUrl: baseUrl),
  );
  final listenProvider = ListenProvider('$baseUrl/websocket');
  final authProvider = AuthProvider(dio);
  final tokenProvider = TokenProvider();
  final userProvider = UserProvider(dio);
  final chatProvider = ChatProvider(dio);
  final chatUserProvider = ChatUserProvider(dio);
  final chatMessageProvider = ChatMessageProvider(dio);
  final friendProvider = FriendProvider(dio);

  final authRepository = AuthRepository(
    authProvider,
    tokenProvider,
    userProvider,
  );
  final listenRepository = ListenRepository(authRepository, listenProvider);
  final userRepository = UserRepository(userProvider);
  final chatRepository = ChatRepository(
    chatProvider,
    chatUserProvider,
    chatMessageProvider,
    listenRepository,
  );
  final friendRepository = FriendRepository(friendProvider, listenRepository);

  dio.interceptors.add(AuthorizationInterceptor(tokenProvider));
  dio.interceptors.add(RefreshInterceptor(dio, tokenProvider, authRepository));

  await authRepository.init();

  runApp(
    App(
      userRepository: userRepository,
      friendRepository: friendRepository,
      authRepository: authRepository,
      chatRepository: chatRepository,
      listenRepository: listenRepository,
    ),
  );
}
