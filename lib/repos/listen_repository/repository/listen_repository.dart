import 'package:talk/providers/chat_providers/chat_providers.dart';
import 'package:talk/repos/auth_repository/auth_repository.dart';

class ListenRepository {
  final AuthRepository _authRepository;
  final ListenProvider _listenProvider;

  ListenRepository(this._authRepository, this._listenProvider) {
    _authRepository.onAuthChanged.listen((auth) {
      if (auth == null) {
        _listenProvider.deactivate();
      } else if (auth.emailVerified) {
        _listenProvider.activate(auth.principal);
      }
    });
  }

  late final onConnectedUser = _listenProvider.onConnectedUser;

  Unsubscribe subscribeToChat(OnChatEvent onData) =>
      _listenProvider.subscribeToChat(onData);

  Unsubscribe subscribeToFriend(OnFriendEvent onData) =>
      _listenProvider.subscribeToFriend(onData);

  Unsubscribe subscribeToChatUser(Chat chat, OnChatUserEvent onData) =>
      _listenProvider.subscribeToChatUser(chat, onData);

  Unsubscribe subscribeToChatMessage(Chat chat, OnChatMessageEvent onData) =>
      _listenProvider.subscribeToChatMessage(chat, onData);
}
