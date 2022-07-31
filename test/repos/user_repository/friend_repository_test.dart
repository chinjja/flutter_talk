// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talk/repos/repos.dart';

import '../../mocks/mocks.dart';

void main() {
  group('fetchFriends()', () {
    late FriendProvider friendProvider;
    late ListenRepository listenRepository;
    late FriendRepository friendRepository;

    setUp(() {
      friendProvider = MockFriendProvider();
      listenRepository = MockListenRepository();

      when(() => listenRepository.onConnectedUser)
          .thenAnswer((_) => Stream.value(null));

      friendRepository = FriendRepository(friendProvider, listenRepository);
    });
    test('when fetch then emit item', () async {
      final friends = [
        Friend(user: User(username: 'a')),
        Friend(user: User(username: 'b')),
      ];
      when(() => friendProvider.getFriends()).thenAnswer((_) async => friends);

      friendRepository.fetchFriends();

      await expectLater(friendRepository.onFriends, emits(friends));
    });
  });
}
