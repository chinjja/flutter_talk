// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talk/repos/repos.dart';

import '../../mocks/mocks.dart';

void main() {
  group('ChatRepository', () {
    late AuthRepository authRepository;
    late ChatProvider chatProvider;
    late ChatUserProvider chatUserProvider;
    late ChatMessageProvider chatMessageProvider;
    late FriendProvider friendProvider;
    late ChatListenProvider chatListenProvider;

    late ChatRepository chatRepository;

    setUp(() {
      authRepository = MockAuthRepository();
      chatProvider = MockChatProvider();
      chatUserProvider = MockChatUserProvider();
      chatMessageProvider = MockChatMessageProvider();
      friendProvider = MockFriendProvider();
      chatListenProvider = MockChatListenProvider();
    });

    test('activate listen', () async {
      final user = User(username: 'user');
      final auth = Authentication(
        principal: user,
        emailVerified: true,
      );
      when(() => authRepository.onAuthChanged).thenAnswer(
        (_) => Stream.value(auth),
      );
      when(() => friendProvider.getFriends()).thenAnswer((_) async => []);
      when(() => chatProvider.getChats(type: ChatType.join)).thenAnswer(
        (_) async => [],
      );
      when(() => chatListenProvider.activate(user)).thenReturn(null);

      when(() => chatListenProvider.onChatChanged).thenAnswer(
        (_) => Stream.empty(),
      );
      when(() => chatListenProvider.onFriendChanged).thenAnswer(
        (_) => Stream.empty(),
      );
      when(() => chatListenProvider.onChatMessageChanged).thenAnswer(
        (_) => Stream.empty(),
      );
      when(() => chatListenProvider.onChatUserChanged).thenAnswer(
        (_) => Stream.empty(),
      );

      chatRepository = ChatRepository(
        authRepository,
        chatProvider,
        chatUserProvider,
        chatMessageProvider,
        friendProvider,
        chatListenProvider,
      );

      await expectLater(chatRepository.onJoinedChats, emits([]));

      verify(() => authRepository.onAuthChanged).called(1);
      verify(() => chatListenProvider.activate(user)).called(1);
    });

    test('deactivate listen', () async {
      when(() => authRepository.onAuthChanged).thenAnswer(
        (_) => Stream.value(null),
      );
      when(() => chatListenProvider.deactivate()).thenReturn(null);

      chatRepository = ChatRepository(
        authRepository,
        chatProvider,
        chatUserProvider,
        chatMessageProvider,
        friendProvider,
        chatListenProvider,
      );

      await Future.delayed(const Duration(milliseconds: 100));

      verify(() => authRepository.onAuthChanged).called(1);
      verify(() => chatListenProvider.deactivate()).called(1);
    });

    group('unauthorized', () {
      setUp(() {
        when(() => authRepository.onAuthChanged).thenAnswer(
          (_) => Stream.value(null),
        );

        chatRepository = ChatRepository(
          authRepository,
          chatProvider,
          chatUserProvider,
          chatMessageProvider,
          friendProvider,
          chatListenProvider,
        );
      });

      group('read()', () {
        test('test name', () {
          final chat = Chat(id: 1, createdAt: DateTime.now());
          when(() => chatProvider.read(chat: chat)).thenAnswer((_) async => {});

          chatRepository.read(chat: chat);

          verify(() => chatProvider.read(chat: chat)).called(1);
          verifyNoMoreInteractions(chatProvider);
        });
      });

      group('fetchJoinedChats()', () {
        test('when fetch then emit item', () async {
          final chats = [
            Chat(id: 1, createdAt: DateTime.now()),
            Chat(id: 2, createdAt: DateTime.now()),
          ];
          final info = ChatInfo(
            userCount: 10,
            unreadCount: 10,
            latestMessage: ChatMessage(
              chat: chats[0],
              id: 1,
              instant: DateTime.now(),
              message: 'hello',
              sender: User(username: 'user'),
            ),
          );
          final res = chats.map((e) => ChatItem(chat: e, info: info)).toList();
          when(() => chatProvider.getChats(type: ChatType.join))
              .thenAnswer((_) async => chats);
          when(() => chatProvider.getChatInfo(chat: chats[0]))
              .thenAnswer((_) async => info);
          when(() => chatProvider.getChatInfo(chat: chats[1]))
              .thenAnswer((_) async => info);

          chatRepository.fetchJoinedChats();

          await expectLater(chatRepository.onJoinedChats, emits(res));
        });
      });

      group('fetchFriends()', () {
        test('when fetch then emit item', () async {
          final friends = [
            User(username: 'a'),
            User(username: 'b'),
          ];
          when(() => friendProvider.getFriends())
              .thenAnswer((_) async => friends);

          chatRepository.fetchFriends();

          await expectLater(chatRepository.onFriends, emits(friends));
        });
      });
    });
  });
}
