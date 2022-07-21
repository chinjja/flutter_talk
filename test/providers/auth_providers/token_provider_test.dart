// ignore_for_file: prefer_const_constructors

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talk/repos/repos.dart';

import '../../mocks/mocks.dart';

void main() {
  group('TokenProvider', () {
    late FlutterSecureStorage storage;
    late TokenProvider tokenProvider;

    setUp(() {
      storage = MockFlutterSecureStorage();
      tokenProvider = TokenProvider(storage);
    });

    group('read()', () {
      test('when both is not null then return token', () async {
        when(() => storage.read(key: 'ACCESS_TOKEN'))
            .thenAnswer((_) async => 'a');
        when(() => storage.read(key: 'REFRESH_TOKEN'))
            .thenAnswer((_) async => 'r');

        final token = await tokenProvider.read();
        expect(token, Token(accessToken: 'a', refreshToken: 'r'));

        verify(() => storage.read(key: 'ACCESS_TOKEN')).called(1);
        verify(() => storage.read(key: 'REFRESH_TOKEN')).called(1);
        verifyNoMoreInteractions(storage);
      });
      test('when accessToken is null then return null', () async {
        when(() => storage.read(key: 'ACCESS_TOKEN'))
            .thenAnswer((_) async => null);
        when(() => storage.read(key: 'REFRESH_TOKEN'))
            .thenAnswer((_) async => 'r');

        final token = await tokenProvider.read();
        expect(token, isNull);

        verify(() => storage.read(key: 'ACCESS_TOKEN')).called(1);
        verify(() => storage.read(key: 'REFRESH_TOKEN')).called(1);
        verifyNoMoreInteractions(storage);
      });
      test('when refreshaccessToken is null then return null', () async {
        when(() => storage.read(key: 'ACCESS_TOKEN'))
            .thenAnswer((_) async => 'a');
        when(() => storage.read(key: 'REFRESH_TOKEN'))
            .thenAnswer((_) async => null);

        final token = await tokenProvider.read();
        expect(token, isNull);

        verify(() => storage.read(key: 'ACCESS_TOKEN')).called(1);
        verify(() => storage.read(key: 'REFRESH_TOKEN')).called(1);
        verifyNoMoreInteractions(storage);
      });

      test('when first read() is called then read() should return cached toekn',
          () async {
        when(() => storage.read(key: 'ACCESS_TOKEN'))
            .thenAnswer((_) async => 'a');
        when(() => storage.read(key: 'REFRESH_TOKEN'))
            .thenAnswer((_) async => 'r');

        await tokenProvider.read();
        final token = await tokenProvider.read();
        expect(token, Token(accessToken: 'a', refreshToken: 'r'));

        verify(() => storage.read(key: 'ACCESS_TOKEN')).called(1);
        verify(() => storage.read(key: 'REFRESH_TOKEN')).called(1);
        verifyNoMoreInteractions(storage);
      });
    });

    group('write()', () {
      test('when a token is passed then should write the token', () async {
        when(() => storage.write(key: 'ACCESS_TOKEN', value: 'a'))
            .thenAnswer((_) async => {});
        when(() => storage.write(key: 'REFRESH_TOKEN', value: 'b'))
            .thenAnswer((_) async => {});

        await tokenProvider.write(Token(accessToken: 'a', refreshToken: 'b'));

        verify(() => storage.write(key: 'ACCESS_TOKEN', value: 'a')).called(1);
        verify(() => storage.write(key: 'REFRESH_TOKEN', value: 'b')).called(1);
        verifyNoMoreInteractions(storage);
      });
    });

    group('clear()', () {
      test('should delete the token', () async {
        when(() => storage.delete(key: 'ACCESS_TOKEN'))
            .thenAnswer((_) async => {});
        when(() => storage.delete(key: 'REFRESH_TOKEN'))
            .thenAnswer((_) async => {});

        await tokenProvider.clear();

        verify(() => storage.delete(key: 'ACCESS_TOKEN')).called(1);
        verify(() => storage.delete(key: 'REFRESH_TOKEN')).called(1);
        verifyNoMoreInteractions(storage);
      });
    });
  });
}
