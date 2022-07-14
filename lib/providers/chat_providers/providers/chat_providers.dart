import 'package:dio/dio.dart';

import '../../providers.dart';

enum ChatType {
  open,
  join,
}

class ChatProvider {
  final Dio _dio;
  ChatProvider(this._dio);

  Future<List<Chat>> getChats({required ChatType type}) async {
    final res = await _dio.get(
      '/chats',
      queryParameters: {
        'type': type.name,
      },
    );
    final list = List.castFrom(res.data);
    return list.map((e) => Chat.fromJson(e)).toList();
  }

  Future<Chat> getChat(int id) async {
    final res = await _dio.get('/chats/$id');
    return Chat.fromJson(res.data);
  }

  Future<int> createOpenChat({
    required String title,
  }) async {
    final res = await _dio.post(
      '/chats/open',
      data: {
        'title': title,
      },
    );
    return res.data;
  }

  Future<int> createGroupChat({
    required String title,
    required List<User> users,
  }) async {
    final res = await _dio.post(
      '/chats/group',
      data: {
        'title': title,
        'usernameList': users.map((e) => e.username).toList(),
      },
    );
    return res.data;
  }

  Future<int> createDirectChat({
    required User other,
  }) async {
    final res = await _dio.post(
      '/chats/direct',
      data: {
        'username': other.username,
      },
    );
    return res.data;
  }

  Future<ChatInfo> getChatInfo({required Chat chat}) async {
    final res = await _dio.get('/chats/${chat.id}/info');
    return ChatInfo.fromJson(res.data);
  }

  Future<void> read({required Chat chat}) async {
    await _dio.post('/chats/${chat.id}/read');
  }
}
