import 'dart:convert';
import 'dart:typed_data';

import '../../providers.dart';

class UserProvider {
  final ApiClient _client;

  UserProvider(this._client);

  Future<User> get({required String username}) async {
    final res = await _client.get(
      _client.uri('/users/$username'),
    );
    final json = jsonDecode(res.body);
    return User.fromJson(json);
  }

  Future<User> update({String? name, String? state, Uint8List? photo}) async {
    final res = await _client.put(
      _client.uri('/users/me'),
      body: jsonEncode({
        'name': name,
        'state': state,
        'photo': photo,
      }),
    );
    final json = jsonDecode(res.body);
    return User.fromJson(json);
  }
}
