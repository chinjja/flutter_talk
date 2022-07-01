import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_handler.dart';

import '../models/models.dart';

class ChatRepository {
  final Dio _dio;
  final AuthRepository _authRepository;
  StompClient? _client;
  final _joinedChatsChanged = BehaviorSubject<List<Chat>>();
  final _friendsChanged = BehaviorSubject<List<User>>();
  final _chatToMessageAdded = <int, PublishSubject<ChatMessage>>{};
  final _chatToUserAdded = <int, PublishSubject<List<ChatUser>>>{};
  final _chatToUserRemoved = <int, PublishSubject<List<ChatUser>>>{};
  final _chatUnsubscribe = <int, StompUnsubscribe>{};

  ChatRepository({
    required AuthRepository authRepository,
    required Dio dio,
  })  : _dio = dio,
        _authRepository = authRepository {
    _authRepository.onUserChanged.listen((user) {
      if (user == null) {
        _deactivate();
      } else {
        _activate(user);
      }
    });
  }

  Stream<List<Chat>> get onJoinedChatsChanged => _joinedChatsChanged.stream;
  Stream<List<User>> get onFriendsChanged => _friendsChanged.stream;

  Stream<ChatMessage> onChatMessageAdded({required Chat chat}) {
    return _chatToMessageAdded[chat.id]!;
  }

  Stream<List<ChatUser>> onChatUserAdded({required Chat chat}) {
    return _chatToUserAdded[chat.id]!;
  }

  Stream<List<ChatUser>> onChatUserRemoved({required Chat chat}) {
    return _chatToUserRemoved[chat.id]!;
  }

  void _activate(User user) {
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
          getFriends().then((data) => _friendsChanged.add(data));
          getJoinedChats().then((chats) {
            for (final chat in chats) {
              _chatUnsubscribe[chat.id] = _listenChat(chat: chat);
            }
            _joinedChatsChanged.add(chats);
          });

          _listenUser();
        },
        onWebSocketError: (e) {
          log(e.toString());
        },
      ),
    );
    if (_client!.isActive) return;

    _client?.activate();
  }

  void _deactivate() {
    _client?.deactivate();
  }

  StompUnsubscribe _listenUser() {
    return _client!.subscribe(
      destination: '/user/topic/changed',
      callback: (frame) async {
        final data = UserChangedData.fromJson(json.decode(frame.body!));
        switch (data.type) {
          case 'create-chat':
            final chat = Chat.fromJson(data.data);
            _chatUnsubscribe[chat.id] = _listenChat(chat: chat);
            final chats = await _joinedChatsChanged.first;
            _joinedChatsChanged.add([chat, ...chats]);
            break;
          case 'delete-chat':
            final chat = Chat.fromJson(data.data);
            _chatUnsubscribe[chat.id]?.call();
            final chats = await _joinedChatsChanged.first;
            _joinedChatsChanged.add([...chats.where((e) => e.id != chat.id)]);
            break;
          case 'friend-added':
            final friend = User.fromJson(data.data);
            final friends = await _friendsChanged.first;
            _friendsChanged.add([friend, ...friends]);
            break;
          case 'friend-removed':
            final friend = User.fromJson(data.data);
            final friends = await _friendsChanged.first;
            _friendsChanged.add(
              [...friends.where((e) => e.username != friend.username)],
            );
            break;
        }
      },
    );
  }

  StompUnsubscribe _listenChat({
    required Chat chat,
  }) {
    final addMessageSubject =
        _chatToMessageAdded.putIfAbsent(chat.id, () => PublishSubject());
    final addUsersSubject =
        _chatToUserAdded.putIfAbsent(chat.id, () => PublishSubject());
    final removeUsersSubject =
        _chatToUserRemoved.putIfAbsent(chat.id, () => PublishSubject());
    return _client!.subscribe(
      destination: '/topic/chat/${chat.id}',
      callback: (frame) async {
        final data = ChatChangedData.fromJson(json.decode(frame.body!));
        switch (data.type) {
          case 'user-added':
            final user = ChatUser.fromJson(data.data);
            addUsersSubject.add([user]);
            break;
          case 'user-removed':
            final user = ChatUser.fromJson(data.data);
            removeUsersSubject.add([user]);
            break;
          case 'users-added':
            final users = await getChatUsersById(
              chat: chat,
              idList: data.data,
            );
            addUsersSubject.add(users);
            break;
          case 'new-message':
            final message = ChatMessage.fromJson(data.data);
            addMessageSubject.add(message);
            break;
        }
      },
    );
  }

  Future<List<Chat>> getOpenChats() async {
    final res = await _dio.get(
      '/chats/open',
    );
    final list = List.castFrom(res.data);
    return list.map((e) => Chat.fromJson(e)).toList();
  }

  Future<void> fetchJoinedChats() async {
    final chats = await getJoinedChats();
    _joinedChatsChanged.add(chats);
  }

  Future<List<Chat>> getJoinedChats() async {
    final res = await _dio.get('/chats/joined');
    final list = List.castFrom(res.data);
    return list.map((e) => Chat.fromJson(e)).toList();
  }

  Future<Chat> getChat(int id) async {
    final res = await _dio.get('/chats/$id');
    return Chat.fromJson(res.data);
  }

  Future<int> createOpenChat({
    required String title,
  }) async {
    final res = await _dio.post(
      '/chats/open',
      data: {
        'title': title,
      },
    );
    return res.data;
  }

  Future<int> createGroupChat({
    required String title,
    required List<User> users,
  }) async {
    final res = await _dio.post(
      '/chats/group',
      data: {
        'title': title,
        'usernameList': users.map((e) => e.username).toList(),
      },
    );
    return res.data;
  }

  Future<int> createDirectChat({
    required User other,
  }) async {
    final res = await _dio.post(
      '/chats/direct',
      data: {
        'username': other.username,
      },
    );
    return res.data;
  }

  Future<int> sendMessage({
    required Chat chat,
    required String message,
  }) async {
    final res = await _dio.post(
      '/chats/${chat.id}/messages',
      data: {
        'message': message,
      },
    );
    return res.data;
  }

  Future<ChatMessage> getMessage({
    required Chat chat,
    required int id,
  }) async {
    final res = await _dio.get('/chats/${chat.id}/messages/$id');
    return ChatMessage.fromJson(res.data);
  }

  Future<List<ChatMessage>> getMessages({
    required Chat chat,
    int limit = 50,
    ChatMessage? from,
  }) async {
    final res = await _dio.get(
      '/chats/${chat.id}/messages',
      queryParameters: {
        'limit': limit,
        'from': from?.id,
      },
    );
    final list = List.castFrom(res.data);
    return list.map((e) => ChatMessage.fromJson(e)).toList();
  }

  Future<List<ChatUser>> getChatUsers({required Chat chat}) async {
    final res = await _dio.get('/chats/${chat.id}/users');
    final list = List.castFrom(res.data);
    return list.map((e) => ChatUser.fromJson(e)).toList();
  }

  Future<List<ChatUser>> getChatUsersById(
      {required Chat chat, required List<int> idList}) async {
    final res = await _dio.get(
      '/chats/${chat.id}/users',
      queryParameters: {
        'idList': idList,
      },
    );
    final list = List.castFrom(res.data);
    return list.map((e) => ChatUser.fromJson(e)).toList();
  }

  Future<void> invite({required Chat chat, required List<User> users}) async {
    await _dio.post('/chats/${chat.id}/invite', data: {
      'usernameList': users.map((e) => e.username).toList(),
    });
  }

  Future<int> join({required Chat chat}) async {
    final res = await _dio.post('/chats/${chat.id}/join');
    return res.data;
  }

  Future<void> leave({required Chat chat}) async {
    await _dio.post('/chats/${chat.id}/leave');
  }

  Future<List<User>> getFriends() async {
    final res = await _dio.get('/users/me/friends');
    final list = List.castFrom(res.data);
    return list.map((e) => User.fromJson(e)).toList();
  }

  Future<void> fetchFriends() async {
    final friends = await getFriends();
    _friendsChanged.add(friends);
  }

  Future<void> addFriend({
    required String username,
  }) async {
    await _dio.post(
      '/users/me/friends',
      data: {
        'username': username,
      },
    );
  }

  Future<void> removeFriend({
    required User friend,
  }) async {
    await _dio.delete('/users/me/friends/${friend.username}');
  }
}

typedef ChatChanged = void Function(ChatChangedData data);
typedef UserChanged = void Function(UserChangedData data);
