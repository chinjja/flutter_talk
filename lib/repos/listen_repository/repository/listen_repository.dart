import 'package:talk/providers/chat_providers/chat_providers.dart';

class ListenRepository {
  final ListenProvider _listenProvider;

  ListenRepository(this._listenProvider);

  late final onConnectedUser = _listenProvider.onConnectedUser;

  Unsubscribe subscribeToChat(OnChatEvent onData) =>
      _listenProvider.subscribeToChat(onData);

  Unsubscribe subscribeToFriend(OnFriendEvent onData) =>
      _listenProvider.subscribeToFriend(onData);

  Unsubscribe subscribeToChatUser(Chat chat, OnChatUserEvent onData) =>
      _listenProvider.subscribeToChatUser(chat, onData);

  Unsubscribe subscribeToChatMessage(Chat chat, OnChatMessageEvent onData) =>
      _listenProvider.subscribeToChatMessage(chat, onData);

  Unsubscribe subscribeToUser(OnUserEvent onData) =>
      _listenProvider.subscribeToUser(onData);
}
