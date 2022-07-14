import 'package:dio/dio.dart';

import '../chat_providers.dart';

class ChatMessageProvider {
  final Dio _dio;

  ChatMessageProvider(this._dio);

  Future<int> sendMessage({
    required Chat chat,
    required String message,
  }) async {
    final res = await _dio.post(
      '/messages',
      queryParameters: {
        'chatId': chat.id,
      },
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
    final res = await _dio.get('/messages/$id');
    return ChatMessage.fromJson(res.data);
  }

  Future<List<ChatMessage>> getMessages({
    required Chat chat,
    int limit = 50,
    DateTime? from,
  }) async {
    final res = await _dio.get(
      '/messages',
      queryParameters: {
        'chatId': chat.id,
        'limit': limit,
        'from': from,
      },
    );
    final list = List.castFrom(res.data);
    return list.map((e) => ChatMessage.fromJson(e)).toList();
  }
}
