import 'package:dio/dio.dart';

import '../models/storage.dart';

class StorageProvider {
  final Dio _dio;

  StorageProvider(this._dio);

  Future<StorageData> get({required String id}) async {
    final res = await _dio.get('/storage/$id');
    return StorageData.fromJson(res.data);
  }

  Future<void> delete({required String id}) async {
    await _dio.delete('/storage/$id');
  }

  Future<StorageId> save(Storage storage) async {
    final res = await _dio.post('/storage', data: storage.toJson());
    return StorageId.fromJson(res.data);
  }
}
