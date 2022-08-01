import 'dart:convert';

import '../chat_providers.dart';

class ChatMessageProvider {
  final ApiClient _client;

  ChatMessageProvider(this._client);

  Future<int> sendMessage({
    required Chat chat,
    required String message,
  }) async {
    final res = await _client.post(
      _client.uri(
        '/messages',
        {'chatId': chat.id},
      ),
      body: jsonEncode({
        'message': message,
      }),
    );
    final json = jsonDecode(res.body);
    return json;
  }

  Future<ChatMessage> getMessage({
    required int id,
  }) async {
    final res = await _client.get(
      _client.uri('/messages/$id'),
    );
    final json = jsonDecode(res.body);
    return ChatMessage.fromJson(json);
  }

  Future<List<ChatMessage>> getMessages({
    required Chat chat,
    int limit = 50,
    DateTime? from,
  }) async {
    final res = await _client.get(
      _client.uri('/messages', {
        'chatId': chat.id,
        'limit': limit,
        'from': from,
      }),
    );
    final json = jsonDecode(res.body);
    final list = List.castFrom(json);
    return list.map((e) => ChatMessage.fromJson(e)).toList();
  }
}
