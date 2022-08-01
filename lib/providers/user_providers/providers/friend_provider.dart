import 'dart:convert';

import '../../providers.dart';

class FriendProvider {
  final ApiClient _client;

  FriendProvider(this._client);

  Future<List<Friend>> getFriends() async {
    final res = await _client.get(
      _client.uri('/friends'),
    );
    final json = jsonDecode(res.body);
    final list = List.castFrom(json);
    return list.map((e) => Friend.fromJson(e)).toList();
  }

  Future<Friend> getFriend(String username) async {
    final res = await _client.get(
      _client.uri('/friends/$username'),
    );
    final json = jsonDecode(res.body);
    return Friend.fromJson(json);
  }

  Future<void> addFriend({
    required String username,
  }) async {
    await _client.post(
      _client.uri('/friends'),
      body: jsonEncode({
        'username': username,
      }),
    );
  }

  Future<void> removeFriend({
    required User friend,
  }) async {
    await _client.delete(
      _client.uri('/friends/${friend.username}'),
    );
  }
}
