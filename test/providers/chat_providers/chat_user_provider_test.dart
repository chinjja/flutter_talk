// ignore_for_file: prefer_const_constructors

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talk/providers/chat_providers/chat_providers.dart';

import '../../fakes/fakes.dart';
import '../../mocks/mocks.dart';

void main() {
  group('ChatUserProvider', () {
    late Dio dio;
    late ChatUserProvider chatUserProvider;

    setUp(() {
      dio = MockDio();
      chatUserProvider = ChatUserProvider(dio);
    });

    group('getChatUsers()', () {
      test('when only chat is passed then returns all users', () async {
        final chat = Chat(id: 1, createdAt: DateTime.now());
        final user = User(username: 'user');
        final users = [
          ChatUser(id: 2, chat: chat, user: user, readAt: DateTime.now()),
          ChatUser(id: 3, chat: chat, user: user, readAt: DateTime.now()),
        ];
        when(() => dio.get('/chat-users', queryParameters: {'chatId': chat.id}))
            .thenAnswer(
          (_) async => FakeResponse(
            data: users.map((e) => e.toJson()).toList(),
          ),
        );

        final res = await chatUserProvider.getChatUsers(chat: chat);
        expect(res, users);
      });

      test('when chat and id list is passed then returns user that contains id',
          () async {
        final chat = Chat(id: 1, createdAt: DateTime.now());
        final user = User(username: 'user');
        final users = [
          ChatUser(id: 2, chat: chat, user: user, readAt: DateTime.now()),
          ChatUser(id: 3, chat: chat, user: user, readAt: DateTime.now()),
        ];
        when(() => dio.get('/chat-users', queryParameters: {
              'chatId': chat.id,
              'idList': [2, 3],
            })).thenAnswer(
          (_) async => FakeResponse(
            data: users.map((e) => e.toJson()).toList(),
          ),
        );

        final res = await chatUserProvider.getChatUsers(
          chat: chat,
          idList: [2, 3],
        );
        expect(res, users);
      });
    });

    group('invite()', () {
      test('when arguments is passed then ok', () async {
        final chat = Chat(id: 1, createdAt: DateTime.now());
        final users = [
          User(username: 'a'),
          User(username: 'b'),
        ];
        when(() => dio.post(
              '/chat-users/invite',
              queryParameters: {
                'chatId': chat.id,
              },
              data: {
                'usernameList': ['a', 'b'],
              },
            )).thenAnswer((_) async => FakeResponse());

        await chatUserProvider.invite(chat: chat, users: users);

        verify(() => dio.post(
              '/chat-users/invite',
              queryParameters: {
                'chatId': chat.id,
              },
              data: {
                'usernameList': ['a', 'b'],
              },
            )).called(1);
        verifyNoMoreInteractions(dio);
      });
    });

    group('join()', () {
      test('when chat is passed then return chatUser id', () async {
        final chat = Chat(id: 1, createdAt: DateTime.now());

        when(() => dio.post('/chat-users/join', queryParameters: {
              'chatId': chat.id,
            })).thenAnswer((_) async => FakeResponse(data: 2));

        final res = await chatUserProvider.join(chat: chat);
        expect(res, 2);
      });
    });

    group('leave()', () {
      test('when chat is passed then return', () async {
        final chat = Chat(id: 1, createdAt: DateTime.now());

        when(() => dio.post('/chat-users/leave', queryParameters: {
              'chatId': chat.id,
            })).thenAnswer((_) async => FakeResponse());

        await chatUserProvider.leave(chat: chat);

        verify(() => dio.post('/chat-users/leave', queryParameters: {
              'chatId': chat.id,
            })).called(1);
        verifyNoMoreInteractions(dio);
      });
    });
  });
}
