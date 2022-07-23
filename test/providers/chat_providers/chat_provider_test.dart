// ignore_for_file: prefer_const_constructors

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talk/providers/chat_providers/chat_providers.dart';

import '../../fakes/fakes.dart';
import '../../mocks/mocks.dart';

void main() {
  group('ChatProvider', () {
    late Dio dio;
    late ChatProvider chatProvider;

    setUp(() {
      dio = MockDio();
      chatProvider = ChatProvider(dio);
    });

    group('getChats()', () {
      test('when type is join then return joined chat list', () async {
        final data = [
          Chat(id: 1, createdAt: DateTime.now()),
          Chat(id: 2, createdAt: DateTime.now()),
        ];
        when(() => dio.get('/chats', queryParameters: {'type': 'join'}))
            .thenAnswer((_) async {
          return FakeResponse(
            data: data.map((e) => e.toJson()).toList(),
          );
        });
        final res = await chatProvider.getChats(type: ChatType.join);
        expect(res, data);

        verify(() => dio.get('/chats', queryParameters: {'type': 'join'}))
            .called(1);
        verifyNoMoreInteractions(dio);
      });
    });

    group('getChat(id)', () {
      test('when is exists then returns a chat', () async {
        final chat = Chat(id: 1, createdAt: DateTime.now());
        when(() => dio.get('/chats/1')).thenAnswer(
          (_) async => FakeResponse(
            data: chat.toJson(),
          ),
        );

        final res = await chatProvider.getChat(1);
        expect(res, chat);

        verify(() => dio.get('/chats/1')).called(1);
        verifyNoMoreInteractions(dio);
      });
    });

    group('createOpenChat()', () {
      test('when title is passed then returns an id', () async {
        final data = {'title': 'a'};
        when(() => dio.post('/chats/open', data: data)).thenAnswer(
          (_) async => FakeResponse(data: 1),
        );
        final chatId = await chatProvider.createOpenChat(title: 'a');
        expect(chatId, 1);

        verify(() => dio.post('/chats/open', data: data)).called(1);
        verifyNoMoreInteractions(dio);
      });
    });

    group('createGroupChat()', () {
      test('when title and user list is pased then returns an id', () async {
        final data = {
          'title': 'a',
          'usernameList': ['b', 'c'],
        };
        when(() => dio.post('/chats/group', data: data)).thenAnswer(
          (_) async => FakeResponse(data: 1),
        );
        final chatId = await chatProvider.createGroupChat(
            title: 'a', users: [User(username: 'b'), User(username: 'c')]);
        expect(chatId, 1);

        verify(() => dio.post('/chats/group', data: data)).called(1);
        verifyNoMoreInteractions(dio);
      });
    });

    group('createDirectChat()', () {
      test('when other username is passed then returns an id', () async {
        final other = User(username: 'other');
        final data = {
          'username': 'other',
        };
        when(() => dio.post('/chats/direct', data: data)).thenAnswer(
          (_) async => FakeResponse(data: 1),
        );
        final chatId = await chatProvider.createDirectChat(other: other);
        expect(chatId, 1);

        verify(() => dio.post('/chats/direct', data: data)).called(1);
        verifyNoMoreInteractions(dio);
      });
    });

    group('getChatInfo()', () {
      test('when chat is passed then returns a chat info', () async {
        final sender = User(username: 'sender');
        final chat = Chat(id: 1, createdAt: DateTime.now());
        final msg = ChatMessage(
          id: 2,
          sender: sender,
          message: 'greeting',
          instant: DateTime.now(),
        );
        final info = ChatInfo(userCount: 1, unreadCount: 2, latestMessage: msg);
        when(() => dio.get('/chats/1/info'))
            .thenAnswer((_) async => FakeResponse(data: info.toJson()));
        final res = await chatProvider.getChatInfo(chat: chat);
        expect(res, info);

        verify(() => dio.get('/chats/1/info')).called(1);
        verifyNoMoreInteractions(dio);
      });
    });

    group('read()', () {
      test('when chat is pased then update principal', () async {
        final chat = Chat(id: 1, createdAt: DateTime.now());
        when(() => dio.post('/chats/1/read'))
            .thenAnswer((_) async => FakeResponse());

        await chatProvider.read(chat: chat);

        verify(() => dio.post('/chats/1/read')).called(1);
        verifyNoMoreInteractions(dio);
      });
    });
  });
}
