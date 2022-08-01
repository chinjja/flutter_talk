import 'dart:convert';

import 'package:talk/providers/chat_providers/chat_providers.dart';

class StorageProvider {
  final ApiClient _client;

  StorageProvider(this._client);

  Future<StorageData> get({required String id}) async {
    final res = await _client.get(
      _client.uri('/storage/$id'),
    );
    final json = jsonDecode(res.body);
    return StorageData.fromJson(json);
  }

  Future<void> delete({required String id}) async {
    await _client.delete(
      _client.uri('/storage/$id'),
    );
  }

  Future<StorageId> save(Storage storage) async {
    final res = await _client.post(
      _client.uri('/storage'),
      body: jsonEncode(storage.toJson()),
    );
    final json = jsonDecode(res.body);
    return StorageId.fromJson(json);
  }
}
