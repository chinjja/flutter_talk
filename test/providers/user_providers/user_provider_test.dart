// ignore_for_file: prefer_const_constructors

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talk/providers/providers.dart';

import '../../fakes/fakes.dart';
import '../../mocks/mocks.dart';

void main() {
  group('UserProvider', () {
    late Dio dio;
    late UserProvider userProvider;

    late User user;

    setUp(() {
      dio = MockDio();
      user = User(username: 'user');
      userProvider = UserProvider(dio);
    });

    test('get() return user', () async {
      when(() => dio.get('/users/user'))
          .thenAnswer((_) async => FakeResponse(data: user.toJson()));

      final res = await userProvider.get(username: 'user');
      expect(res, user);
    });

    test('update()', () async {
      when(() => dio.put('/users/me', data: {
            'name': 'hello',
            'state': 'world',
            'photo': null,
          })).thenAnswer((_) async => FakeResponse(data: user.toJson()));
      final res = await userProvider.update(name: 'hello', state: 'world');
      expect(res, user);
    });
  });
}
