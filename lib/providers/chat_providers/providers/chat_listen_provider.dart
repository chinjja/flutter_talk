import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_handler.dart';

import '../chat_providers.dart';

class ChatListenProvider {
  final Dio _dio;
  final ChatProvider _chatProvider;

  StompClient? _client;

  final _chatChanged = PublishSubject<ChatChanged<Chat>>();
  final _friendChanged = PublishSubject<ChatChanged<Friend>>();

  final _messageChanegd = PublishSubject<ChatChanged<ChatMessage>>();
  final _chatUserChanged = PublishSubject<ChatChanged<ChatUser>>();

  final _chatUnsubscribe = <int, StompUnsubscribe>{};

  ChatListenProvider(this._dio, this._chatProvider);

  Stream<ChatChanged<Chat>> get onChatChanged => _chatChanged.stream;
  Stream<ChatChanged<Friend>> get onFriendChanged => _friendChanged.stream;
  Stream<ChatChanged<ChatMessage>> get onChatMessageChanged =>
      _messageChanegd.stream;
  Stream<ChatChanged<ChatUser>> get onChatUserChanged =>
      _chatUserChanged.stream;

  void activate(User user) {
    _client ??= StompClient(
      config: StompConfig.SockJS(
        url: '${_dio.options.baseUrl}/websocket',
        stompConnectHeaders: {
          'username': user.username,
        },
        beforeConnect: () async {
          log('trying connection');
        },
        onConnect: (frame) async {
          log('conntected');
          _chatProvider.getChats(type: ChatType.join).then((chats) {
            for (final chat in chats) {
              _listenChat(chat: chat);
            }
          });

          _listenUser();
        },
        onDisconnect: (frame) {
          _unlistenChatAll();
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

  StompUnsubscribe _listenUser() {
    return _client!.subscribe(
      destination: '/user/topic/changed',
      callback: (frame) async {
        final data = ChatChangedData.fromJson(json.decode(frame.body!));
        switch (data.objectType) {
          case 'Chat':
            final chat = Chat.fromJson(data.data);
            _chatChanged.add(ChatChanged(
              chatId: data.chatId,
              command: data.command,
              data: chat,
            ));
            switch (data.command) {
              case 'added':
                _listenChat(chat: chat);
                break;
              case 'removed':
                _unlistenChat(chat: chat);
                break;
            }
            break;
          case 'Friend':
            final friend = Friend.fromJson(data.data);
            _friendChanged.add(ChatChanged(
              chatId: data.chatId,
              command: data.command,
              data: friend,
            ));
            break;
        }
      },
    );
  }

  void _unlistenChatAll() {
    for (final un in _chatUnsubscribe.values) {
      un();
    }
    _chatUnsubscribe.clear();
  }

  void _unlistenChat({
    required Chat chat,
  }) {
    _chatUnsubscribe[chat.id]?.call();
  }

  void _listenChat({
    required Chat chat,
  }) {
    _chatUnsubscribe.putIfAbsent(
      chat.id,
      () => _client!.subscribe(
        destination: '/topic/chat/${chat.id}',
        callback: (frame) async {
          final data = ChatChangedData.fromJson(json.decode(frame.body!));
          switch (data.objectType) {
            case 'ChatUser':
              final chatUser = ChatUser.fromJson(data.data);
              _chatUserChanged.add(ChatChanged(
                chatId: data.chatId,
                command: data.command,
                data: chatUser,
              ));
              break;
            case 'ChatUserList':
              final list = List.castFrom(data.data);
              final chatUsers = list.map((e) => ChatUser.fromJson(e)).toList();
              for (final chatUser in chatUsers) {
                _chatUserChanged.add(ChatChanged(
                  chatId: data.chatId,
                  command: data.command,
                  data: chatUser,
                ));
              }
              break;
            case 'ChatMessage':
              final message = ChatMessage.fromJson(data.data);
              _messageChanegd.add(ChatChanged(
                chatId: data.chatId,
                command: data.command,
                data: message,
              ));
              break;
          }
        },
      ),
    );
  }
}
