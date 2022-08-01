import 'dart:convert';

import '../../providers.dart';

class ChatUserProvider {
  final ApiClient _client;

  ChatUserProvider(this._client);
  Future<List<ChatUser>> getChatUsers({required Chat chat}) async {
    final res = await _client.get(
      _client.uri(
        '/chat-users',
        {
          'chatId': chat.id,
        },
      ),
    );
    final json = jsonDecode(res.body);
    final list = List.castFrom(json);
    return list.map((e) => ChatUser.fromJson(e)).toList();
  }

  Future<void> invite({required Chat chat, required List<User> users}) async {
    await _client.post(
      _client.uri(
        '/chat-users/invite',
        {
          'chatId': chat.id,
        },
      ),
      body: jsonEncode({
        'usernameList': users.map((e) => e.username).toList(),
      }),
    );
  }

  Future<int> join({required Chat chat}) async {
    final res = await _client.post(
      _client.uri(
        '/chat-users/join',
        {
          'chatId': chat.id,
        },
      ),
    );
    final json = jsonDecode(res.body);
    return json;
  }

  Future<void> leave({required Chat chat}) async {
    await _client.post(
      _client.uri(
        '/chat-users/leave',
        {
          'chatId': chat.id,
        },
      ),
    );
  }
}
