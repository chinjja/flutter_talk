import 'dart:typed_data';

import 'package:dio/dio.dart';

class StorageProvider {
  final Dio _dio;

  StorageProvider(this._dio);

  Future<Uint8List> get({required String id}) async {
    final res = await _dio.get('/storage/$id',
        options: Options(
          responseType: ResponseType.bytes,
        ));
    return res.data;
  }
}
