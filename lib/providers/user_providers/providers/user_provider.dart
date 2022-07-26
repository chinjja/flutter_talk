import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../models/user.dart';

class UserProvider {
  final Dio _dio;

  UserProvider(this._dio);

  Future<User> get({required String username}) async {
    final res = await _dio.get('/users/$username');
    return User.fromJson(res.data);
  }

  Future<User> update({String? name, String? state, Uint8List? photo}) async {
    final res = await _dio.put('/users/me', data: {
      'name': name,
      'state': state,
      'photo': photo,
    });
    return User.fromJson(res.data);
  }
}
