import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:talk/repos/repos.dart';

import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final tokenProvider = TokenProvider();
  const baseUrl = String.fromEnvironment(
    'host.url',
    defaultValue: 'localhost:8080',
  );
  final client = ApiClient(baseUrl, http.Client(), tokenProvider);
  final listenProvider = ListenProvider('http://$baseUrl/websocket');
  final authProvider = AuthProvider(client);
  final userProvider = UserProvider(client);
  final storageProvider = StorageProvider(client);
  final chatProvider = ChatProvider(client);
  final chatUserProvider = ChatUserProvider(client);
  final chatMessageProvider = ChatMessageProvider(client);
  final friendProvider = FriendProvider(client);

  final authRepository = AuthRepository(
    authProvider,
    tokenProvider,
    userProvider,
  );
  final listenRepository = ListenRepository(authRepository, listenProvider);
  final userRepository = UserRepository(userProvider);
  final storageRepository = StorageRepository(storageProvider);
  final chatRepository = ChatRepository(
    chatProvider,
    chatUserProvider,
    chatMessageProvider,
    listenRepository,
  );
  final friendRepository = FriendRepository(friendProvider, listenRepository);

  await authRepository.init();

  runApp(
    App(
      userRepository: userRepository,
      friendRepository: friendRepository,
      authRepository: authRepository,
      chatRepository: chatRepository,
      storageRepository: storageRepository,
      listenRepository: listenRepository,
    ),
  );
}
