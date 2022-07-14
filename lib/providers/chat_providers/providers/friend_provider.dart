import 'package:dio/dio.dart';

import '../../providers.dart';

class FriendProvider {
  final Dio _dio;

  FriendProvider(this._dio);

  Future<List<User>> getFriends() async {
    final res = await _dio.get('/friends');
    final list = List.castFrom(res.data);
    return list.map((e) => User.fromJson(e)).toList();
  }

  Future<User> getFriend(String username) async {
    final res = await _dio.get('/friends/$username');
    return User.fromJson(res.data);
  }

  Future<void> addFriend({
    required String username,
  }) async {
    await _dio.post(
      '/friends',
      data: {
        'username': username,
      },
    );
  }

  Future<void> removeFriend({
    required User friend,
  }) async {
    await _dio.delete('/friends/${friend.username}');
  }
}
