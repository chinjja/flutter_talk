// ignore_for_file: prefer_const_constructors

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talk/repos/repos.dart';

import '../../fakes/fakes.dart';
import '../../mocks/mocks.dart';

void main() {
  group('AuthProvider', () {
    late Dio dio;
    late AuthProvider authProvider;

    setUp(() {
      dio = MockDio();
      authProvider = AuthProvider(dio);
    });

    test('register()', () async {
      final data = {
        'username': 'user',
        'password': '1234',
      };
      when(() => dio.post('/auth/register', data: data))
          .thenAnswer((_) async => FakeResponse());

      await authProvider.register(username: 'user', password: '1234');

      verify(() => dio.post('/auth/register', data: data)).called(1);
      verifyNoMoreInteractions(dio);
    });

    test('login()', () async {
      final req = {
        'username': 'user',
        'password': '1234',
      };
      final res = LoginResponse(
        emailVerified: true,
        token: Token(accessToken: 'a', refreshToken: 'r'),
      );
      when(() => dio.post('/auth/login', data: req)).thenAnswer((_) async {
        return FakeResponse(
          data: res.toJson(),
        );
      });

      final response =
          await authProvider.login(username: 'user', password: '1234');
      expect(response, res);
      verify(() => dio.post('/auth/login', data: req)).called(1);
      verifyNoMoreInteractions(dio);
    });

    test('logout()', () async {
      when(() => dio.post('/auth/logout'))
          .thenAnswer((_) async => FakeResponse());

      await authProvider.logout();

      verify(() => dio.post('/auth/logout')).called(1);
      verifyNoMoreInteractions(dio);
    });

    test('sendCode()', () async {
      when(() => dio.post('/verification/send-code'))
          .thenAnswer((_) async => FakeResponse());

      await authProvider.sendCode();

      verify(() => dio.post('/verification/send-code')).called(1);
      verifyNoMoreInteractions(dio);
    });

    test('verifyCode()', () async {
      final req = {
        'code': "123123",
      };
      when(() => dio.post('/verification/verify-code', data: req))
          .thenAnswer((_) async => FakeResponse());

      await authProvider.verifyCode("123123");

      verify(() => dio.post('/verification/verify-code', data: req)).called(1);
      verifyNoMoreInteractions(dio);
    });

    test('isVerified()', () async {
      when(() => dio.get('/verification/is-verified')).thenAnswer((_) async {
        return FakeResponse(
          data: true,
        );
      });

      final res = await authProvider.isVerified();
      expect(res, true);

      verify(() => dio.get('/verification/is-verified')).called(1);
      verifyNoMoreInteractions(dio);
    });
  });
}
