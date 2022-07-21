// ignore_for_file: prefer_const_constructors

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talk/providers/chat_providers/chat_providers.dart';

import '../../fakes/fakes.dart';
import '../../mocks/mocks.dart';

void main() {
  group('FriendProvider', () {
    late Dio dio;
    late FriendProvider friendProvider;

    setUp(() {
      dio = MockDio();
      friendProvider = FriendProvider(dio);
    });

    group('getFriends()', () {
      test('return all friends', () async {
        final friends = [
          User(username: 'a'),
          User(username: 'b'),
        ];
        when(() => dio.get('/friends')).thenAnswer((_) async =>
            FakeResponse(data: friends.map((e) => e.toJson()).toList()));

        final res = await friendProvider.getFriends();
        expect(res, friends);
      });
    });

    group('getFriend()', () {
      test('return friend by username', () async {
        final friend = User(username: 'user');

        when(() => dio.get('/friends/user'))
            .thenAnswer((_) async => FakeResponse(data: friend.toJson()));

        final res = await friendProvider.getFriend('user');
        expect(res, friend);
      });
    });

    group('addFriend()', () {
      test('when username is passed then ok', () async {
        when(() => dio.post(
              '/friends',
              data: {'username': 'user'},
            )).thenAnswer((_) async => FakeResponse());

        await friendProvider.addFriend(username: 'user');

        verify(() => dio.post(
              '/friends',
              data: {'username': 'user'},
            )).called(1);
        verifyNoMoreInteractions(dio);
      });
    });

    group('group name', () {
      test('when username is passed then ok', () async {
        final user = User(username: 'user');
        when(() => dio.delete(
              '/friends/user',
            )).thenAnswer((_) async => FakeResponse());

        await friendProvider.removeFriend(friend: user);

        verify(() => dio.delete(
              '/friends/user',
            )).called(1);
        verifyNoMoreInteractions(dio);
      });
    });
  });
}
