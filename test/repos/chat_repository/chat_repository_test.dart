// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talk/repos/repos.dart';

import '../../mocks/mocks.dart';

void main() {
  group('ChatRepository', () {
    late ChatProvider chatProvider;
    late ChatUserProvider chatUserProvider;
    late ChatMessageProvider chatMessageProvider;
    late ListenRepository listenRepository;

    late ChatRepository chatRepository;

    setUp(() {
      chatProvider = MockChatProvider();
      chatUserProvider = MockChatUserProvider();
      chatMessageProvider = MockChatMessageProvider();
      listenRepository = MockListenRepository();

      when(() => listenRepository.onConnectedUser)
          .thenAnswer((_) => Stream.value(null));
    });

    group('unauthorized', () {
      setUp(() {
        chatRepository = ChatRepository(
          chatProvider,
          chatUserProvider,
          chatMessageProvider,
          listenRepository,
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
    });
  });
}
