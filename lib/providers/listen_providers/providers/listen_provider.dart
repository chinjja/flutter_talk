import 'dart:convert';
import 'dart:developer';

import 'package:rxdart/rxdart.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:talk/repos/repos.dart';

class ListenProvider {
  final String url;
  final _onConnectedUser = BehaviorSubject<User?>.seeded(null);
  StompClient? _client;

  ListenProvider(this.url);

  void activate(User user) {
    _client ??= StompClient(
      config: StompConfig.SockJS(
        url: url,
        stompConnectHeaders: {
          'username': user.username,
        },
        onConnect: (frame) async {
          _onConnectedUser.add(user);
        },
        onDisconnect: (frame) {
          _onConnectedUser.add(null);
        },
        onWebSocketError: (e) {
          log(e.toString());
        },
      ),
    );
    if (_client!.isActive) return;

    _client?.activate();
  }

  void deactivate() {
    _client?.deactivate();
  }

  Stream get onConnectedUser => _onConnectedUser.stream;

  Unsubscribe _subscribeToUser(OnChangedEvent onData) {
    return _client!.subscribe(
      destination: '/user/topic/changed',
      callback: (frame) {
        onData(ChangedEvent.fromJson(json.decode(frame.body!)));
      },
    );
  }

  Unsubscribe _subscribe(Chat chat, OnChangedEvent onData) {
    return _client!.subscribe(
      destination: '/topic/chat/${chat.id}',
      callback: (frame) {
        onData(ChangedEvent.fromJson(json.decode(frame.body!)));
      },
    );
  }

  Unsubscribe subscribeToChatMessage(Chat chat, OnChatMessageEvent onData) {
    return _subscribe(chat, (event) {
      if (event.objectType != 'ChatMessage') return;

      onData(ChatMessageEvent(
        command: event.command,
        message: ChatMessage.fromJson(event.data),
      ));
    });
  }

  Unsubscribe subscribeToChatUser(Chat chat, OnChatUserEvent onData) {
    return _subscribe(chat, (event) {
      if (event.objectType != 'ChatUser') return;

      onData(ChatUserEvent(
        command: event.command,
        chatUser: ChatUser.fromJson(event.data),
      ));
    });
  }

  Unsubscribe subscribeToFriend(OnFriendEvent onData) {
    return _subscribeToUser((event) {
      if (event.objectType != 'Friend') return;

      onData(FriendEvent(
        command: event.command,
        friend: Friend.fromJson(event.data),
      ));
    });
  }

  Unsubscribe subscribeToChat(OnChatEvent onData) {
    return _subscribeToUser((event) {
      if (event.objectType != 'Chat') return;

      onData(ChatEvent(
        command: event.command,
        chat: Chat.fromJson(event.data),
      ));
    });
  }
}
