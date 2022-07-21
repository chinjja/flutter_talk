// ignore_for_file: prefer_const_constructors

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talk/providers/chat_providers/chat_providers.dart';

import '../../fakes/fakes.dart';
import '../../mocks/mocks.dart';

void main() {
  group('ChatMessageProvider', () {
    late Dio dio;
    late ChatMessageProvider chatMessageProvider;

    setUp(() {
      dio = MockDio();
      chatMessageProvider = ChatMessageProvider(dio);
    });

    group('sendMessage()', () {
      test('when arguments is passed then return message id', () async {
        final chat = Chat(id: 1, createdAt: DateTime.now());

        when(() => dio.post(
              '/messages',
              queryParameters: {
                'chatId': chat.id,
              },
              data: {
                'message': 'greeting',
              },
            )).thenAnswer((_) async => FakeResponse(data: 2));

        final messageId = await chatMessageProvider.sendMessage(
            chat: chat, message: 'greeting');
        expect(messageId, 2);
      });

      group('getMessage()', () {
        test('when message id is passed then return message', () async {
          final sender = User(username: 'sender');
          final chat = Chat(id: 1, createdAt: DateTime.now());
          final message = ChatMessage(
            id: 2,
            chat: chat,
            sender: sender,
            message: 'greeting',
            instant: DateTime.now(),
          );

          when(() => dio.get(
                '/messages/2',
              )).thenAnswer((_) async => FakeResponse(data: message.toJson()));

          final res = await chatMessageProvider.getMessage(
            id: 2,
          );
          expect(res, message);
        });
      });

      group('getMessages()', () {
        test('when chat ans limit is passed then return message list',
            () async {
          final sender = User(username: 'sender');
          final chat = Chat(id: 1, createdAt: DateTime.now());
          final messages = [
            ChatMessage(
              id: 2,
              chat: chat,
              sender: sender,
              message: 'greeting',
              instant: DateTime.now(),
            )
          ];

          when(() => dio.get(
                    '/messages',
                    queryParameters: {
                      'chatId': chat.id,
                      'limit': 12,
                      'from': null,
                    },
                  ))
              .thenAnswer((_) async =>
                  FakeResponse(data: messages.map((e) => e.toJson()).toList()));

          final res = await chatMessageProvider.getMessages(
            chat: chat,
            limit: 12,
          );
          expect(res, messages);
        });
        test('when chat ans limit ans from is passed then return message list',
            () async {
          final sender = User(username: 'sender');
          final chat = Chat(id: 1, createdAt: DateTime.now());
          final messages = [
            ChatMessage(
              id: 2,
              chat: chat,
              sender: sender,
              message: 'greeting',
              instant: DateTime.now(),
            )
          ];
          final from = DateTime.now();

          when(() => dio.get(
                    '/messages',
                    queryParameters: {
                      'chatId': chat.id,
                      'limit': 12,
                      'from': from,
                    },
                  ))
              .thenAnswer((_) async =>
                  FakeResponse(data: messages.map((e) => e.toJson()).toList()));

          final res = await chatMessageProvider.getMessages(
            chat: chat,
            limit: 12,
            from: from,
          );
          expect(res, messages);
        });
      });
    });
  });
}
