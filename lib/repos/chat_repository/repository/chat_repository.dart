import 'package:rxdart/rxdart.dart';

import '../../repos.dart';

class ChatRepository {
  final ChatProvider _chatProvider;
  final ChatUserProvider _chatUserProvider;
  final ChatMessageProvider _chatMessageProvider;
  final ListenRepository _listenRepository;

  final _joinedChatsChanged = BehaviorSubject<List<ChatItem>>();

  final _chatUnsubscribe = <int, List<Unsubscribe>>{};

  ChatRepository(
    this._chatProvider,
    this._chatUserProvider,
    this._chatMessageProvider,
    this._listenRepository,
  ) {
    _listenRepository.onConnectedUser.listen((user) async {
      if (user == null) {
        _unlistenChatAll();
      } else {
        final chats = await getJoinedChats();
        _joinedChatsChanged.add(chats);

        for (final chat in chats) {
          _listenChat(chat.chat);
        }
        _listenRepository.subscribeToChat((event) async {
          final chat = event.chat;
          final old = await _joinedChatsChanged.first;
          if (event.isAdded) {
            _listenChat(chat);
            final chatItem = await _bindChat(chat);
            _joinedChatsChanged.add([chatItem, ...old]);
          } else if (event.isRemoved) {
            _unlistenChat(chat);
            _joinedChatsChanged
                .add(old.where((e) => e.chat.id != chat.id).toList());
          }
        });
      }
    });
  }

  void _unlistenChatAll() {
    for (final un in _chatUnsubscribe.values) {
      un.map((e) => e.call());
    }
    _chatUnsubscribe.clear();
  }

  void _unlistenChat(Chat chat) {
    _chatUnsubscribe[chat.id]?.map((e) => e.call());
    _chatUnsubscribe.remove(chat.id);
  }

  void _listenChat(Chat chat) {
    final subs = <Unsubscribe>[];

    subs.add(_listenRepository.subscribeToChatMessage(chat, (event) async {
      final message = event.message;
      final old = await _joinedChatsChanged.first;
      if (event.isAdded) {
        final list = old.map((e) {
          if (e.chat.id != chat.id) return e;
          return e.copyWith(
            info: e.info.copyWith(
              latestMessage: message,
              unreadCount: e.info.unreadCount + 1,
            ),
          );
        }).toList();
        list.sort();
        _joinedChatsChanged.add(list);
      }
    }));
    subs.add(_listenRepository.subscribeToChatUser(chat, (event) async {
      final old = await _joinedChatsChanged.first;
      final list = await Stream.fromIterable(old).asyncMap((e) async {
        if (e.chat.id != chat.id) return e;
        if (event.isAdded) {
          return e.copyWith(
            info: e.info.copyWith(
              userCount: e.info.userCount + 1,
              users: [...e.info.users, event.chatUser.user],
            ),
          );
        } else if (event.isRemoved) {
          return e.copyWith(
            info: e.info.copyWith(
              userCount: e.info.userCount - 1,
              users: [
                ...e.info.users
                    .where((e) => e.username == event.chatUser.user.username)
              ],
            ),
          );
        } else if (event.isUpdated) {
          return await _bindChat(e.chat);
        } else {
          return e;
        }
      }).toList();
      _joinedChatsChanged.add(list);
    }));

    _chatUnsubscribe[chat.id] = subs;
  }

  late final onJoinedChats = _joinedChatsChanged.stream;

  Future<void> read({required Chat chat}) async {
    await _chatProvider.read(chat: chat);
  }

  Future<List<Chat>> _getChats({required ChatType type}) async {
    return await _chatProvider.getChats(type: type);
  }

  Future<Chat?> getDirectChat(User user) async {
    return await _chatProvider.getDirectChat(user);
  }

  Future<List<ChatItem>> getJoinedChats() async {
    final chats = await _getChats(type: ChatType.join);
    final list = await Stream.fromIterable(chats)
        .asyncMap((event) => _bindChat(event))
        .toList();
    list.sort();
    return list;
  }

  Future<void> fetchJoinedChats() async {
    final list = await getJoinedChats();
    _joinedChatsChanged.add(list);
  }

  Future<ChatItem> _bindChat(Chat chat) async {
    final info = await _chatProvider.getChatInfo(chat: chat);
    return ChatItem(
      chat: chat,
      info: info,
    );
  }

  Future<Chat> getChat(int id) async {
    return _chatProvider.getChat(id);
  }

  Future<int> createOpenChat({
    required String title,
  }) async {
    return _chatProvider.createOpenChat(title: title);
  }

  Future<int> createGroupChat({
    required String title,
    required List<User> users,
  }) async {
    return _chatProvider.createGroupChat(title: title, users: users);
  }

  Future<int> createDirectChat({
    required User other,
  }) async {
    return _chatProvider.createDirectChat(other: other);
  }

  Future<int> sendMessage({
    required Chat chat,
    required String message,
  }) async {
    return _chatMessageProvider.sendMessage(chat: chat, message: message);
  }

  Future<ChatMessage> getMessage({
    required int id,
  }) async {
    return _chatMessageProvider.getMessage(id: id);
  }

  Future<List<ChatMessage>> getMessages({
    required Chat chat,
    int limit = 50,
    DateTime? from,
  }) async {
    return _chatMessageProvider.getMessages(
      chat: chat,
      from: from,
      limit: limit,
    );
  }

  Future<List<ChatUser>> getChatUsers({
    required Chat chat,
  }) async {
    return _chatUserProvider.getChatUsers(chat: chat);
  }

  Future<void> invite({required Chat chat, required List<User> users}) async {
    await _chatUserProvider.invite(chat: chat, users: users);
  }

  Future<int> join({required Chat chat}) async {
    return _chatUserProvider.join(chat: chat);
  }

  Future<void> leave({required Chat chat}) async {
    await _chatUserProvider.leave(chat: chat);
  }
}
