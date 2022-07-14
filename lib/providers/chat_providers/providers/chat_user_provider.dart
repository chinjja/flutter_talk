import 'package:dio/dio.dart';

import '../../providers.dart';

class ChatUserProvider {
  final Dio _dio;

  ChatUserProvider(this._dio);
  Future<List<ChatUser>> getChatUsers(
      {required Chat chat, List<int>? idList}) async {
    Map<String, dynamic> param = {'chatId': chat.id};
    if (idList != null) {
      param['idList'] = idList;
    }
    final res = await _dio.get(
      '/chat-users',
      queryParameters: param,
    );
    final list = List.castFrom(res.data);
    return list.map((e) => ChatUser.fromJson(e)).toList();
  }

  Future<void> invite({required Chat chat, required List<User> users}) async {
    await _dio.post(
      '/chat-users/invite',
      queryParameters: {
        'chatId': chat.id,
      },
      data: {
        'usernameList': users.map((e) => e.username).toList(),
      },
    );
  }

  Future<int> join({required Chat chat}) async {
    final res = await _dio.post(
      '/chat-users/join',
      queryParameters: {
        'chatId': chat.id,
      },
    );
    return res.data;
  }

  Future<void> leave({required Chat chat}) async {
    await _dio.delete(
      '/chat-users/leave',
      queryParameters: {
        'chatId': chat.id,
      },
    );
  }
}
