import 'package:rxdart/rxdart.dart';

import '../../repos.dart';

class ChatRepository {
  final AuthRepository _authRepository;
  final ChatProvider _chatProvider;
  final ChatUserProvider _chatUserProvider;
  final ChatMessageProvider _chatMessageProvider;
  final FriendProvider _friendProvider;
  final ChatListenProvider _chatListenProvider;

  final _joinedChatsChanged = BehaviorSubject<List<ChatItem>>();
  final _friendsChanged = BehaviorSubject<List<User>>();

  final _subscriptions = CompositeSubscription();

  ChatRepository(
    this._authRepository,
    this._chatProvider,
    this._chatUserProvider,
    this._chatMessageProvider,
    this._friendProvider,
    this._chatListenProvider,
  ) {
    _authRepository.onUserChanged.listen((auth) {
      if (auth == null) {
        _chatListenProvider.deactivate();
        _subscriptions.clear();
      } else if (auth.emailVerified) {
        fetchFriends();
        fetchJoinedChats();
        _chatListenProvider.activate(auth.principal);

        _subscriptions.add(onChatChanged.listen((event) async {
          final chat = event.data;
          final old = await _joinedChatsChanged.first;
          if (event.isAdded) {
            final chatItem = await bindChat(chat);
            _joinedChatsChanged.add([chatItem, ...old]);
          } else if (event.isRemoved) {
            _joinedChatsChanged
                .add(old.where((e) => e.chat.id != chat.id).toList());
          }
        }));
        _subscriptions.add(onFriendChanged.listen((event) async {
          final friend = event.data;
          final old = await _friendsChanged.first;
          if (event.isAdded) {
            _friendsChanged.add([...old, friend]);
          } else if (event.isRemoved) {
            _friendsChanged
                .add(old.where((e) => e.username != friend.username).toList());
          }
        }));
        _subscriptions.add(onChatMessageChanged.listen((event) async {
          final message = event.data;
          final old = await _joinedChatsChanged.first;
          if (event.isAdded) {
            final list = old.map((e) {
              if (e.chat.id != message.chat.id) return e;
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
        _subscriptions.add(onChatUserChanged.listen((event) async {
          final user = event.data;
          final old = await _joinedChatsChanged.first;
          final list = await Stream.fromIterable(old).asyncMap((e) async {
            if (e.chat.id != user.chat.id) return e;
            if (event.isAdded) {
              return e.copyWith(
                info: e.info.copyWith(
                  userCount: e.info.userCount + 1,
                ),
              );
            } else if (event.isRemoved) {
              return e.copyWith(
                info: e.info.copyWith(
                  userCount: e.info.userCount - 1,
                ),
              );
            } else if (event.isUpdated) {
              return await bindChat(e.chat);
            } else {
              return e;
            }
          }).toList();
          _joinedChatsChanged.add(list);
        }));
      }
    });
  }

  late final onJoinedChats = _joinedChatsChanged.stream;
  late final onFriends = _friendsChanged.stream;

  late final onChatChanged = _chatListenProvider.onChatChanged;
  late final onFriendChanged = _chatListenProvider.onFriendChanged;
  late final onChatMessageChanged = _chatListenProvider.onChatMessageChanged;
  late final onChatUserChanged = _chatListenProvider.onChatUserChanged;

  Future<void> read({required Chat chat}) async {
    await _chatProvider.read(chat: chat);
  }

  Future<List<Chat>> getChats({required ChatType type}) async {
    return await _chatProvider.getChats(type: type);
  }

  Future<void> fetchJoinedChats() async {
    final chats = await getChats(type: ChatType.join);
    final list = await Stream.fromIterable(chats)
        .asyncMap((event) => bindChat(event))
        .toList();
    list.sort();
    _joinedChatsChanged.add(list);
  }

  Future<ChatItem> bindChat(Chat chat) async {
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
    required Chat chat,
    required int id,
  }) async {
    return _chatMessageProvider.getMessage(chat: chat, id: id);
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
    List<int>? idList,
  }) async {
    return _chatUserProvider.getChatUsers(chat: chat, idList: idList);
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

  Future<List<User>> getFriends() async {
    return _friendProvider.getFriends();
  }

  Future<void> fetchFriends() async {
    final friends = await getFriends();
    _friendsChanged.add(friends);
  }

  Future<void> addFriend({
    required String username,
  }) async {
    await _friendProvider.addFriend(username: username);
  }

  Future<void> removeFriend({
    required User friend,
  }) async {
    await _friendProvider.removeFriend(friend: friend);
  }
}
