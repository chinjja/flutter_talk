import 'dart:convert';

import '../../providers.dart';

enum ChatType {
  open,
  join,
}

class ChatProvider {
  final ApiClient _client;
  ChatProvider(this._client);

  Future<List<Chat>> getChats({required ChatType type}) async {
    final res = await _client.get(
      _client.uri('/chats', {
        'type': type.name,
      }),
    );
    final json = jsonDecode(res.body);
    final list = List.castFrom(json);
    return list.map((e) => Chat.fromJson(e)).toList();
  }

  Future<Chat> getChat(int id) async {
    final res = await _client.get(
      _client.uri('/chats/$id'),
    );
    final json = jsonDecode(res.body);
    return Chat.fromJson(json);
  }

  Future<int> createOpenChat({
    required String title,
  }) async {
    final res = await _client.post(
      _client.uri('/chats/open'),
      body: jsonEncode({
        'title': title,
      }),
    );
    final json = jsonDecode(res.body);
    return json;
  }

  Future<int> createGroupChat({
    required String title,
    required List<User> users,
  }) async {
    final res = await _client.post(
      _client.uri('/chats/group'),
      body: jsonEncode({
        'title': title,
        'usernameList': users.map((e) => e.username).toList(),
      }),
    );
    final json = jsonDecode(res.body);
    return json;
  }

  Future<int> createDirectChat({
    required User other,
  }) async {
    final res = await _client.post(
      _client.uri('/chats/direct'),
      body: jsonEncode({
        'username': other.username,
      }),
    );
    final json = jsonDecode(res.body);
    return json;
  }

  Future<ChatInfo> getChatInfo({required Chat chat}) async {
    final res = await _client.get(
      _client.uri('/chats/${chat.id}/info'),
    );
    final json = jsonDecode(res.body);
    return ChatInfo.fromJson(json);
  }

  Future<void> read({required Chat chat}) async {
    await _client.post(
      _client.uri('/chats/${chat.id}/read'),
    );
  }
}
