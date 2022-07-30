// ignore_for_file: prefer_const_constructors

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talk/repos/repos.dart';

import '../../mocks/mocks.dart';

void main() {
  group('UserRepository', () {
    late UserProvider userProvider;
    late UserRepository userRepository;
    late User user;
    late Uint8List photo;

    setUp(() {
      userProvider = MockUserProvider();
      userRepository = UserRepository(userProvider);
      user = User(username: 'user');
      photo = Uint8List.fromList([1, 2]);
    });

    test('get() return user', () async {
      when(() => userProvider.get(username: 'user'))
          .thenAnswer((_) async => user);

      final res = await userRepository.get(username: 'user');
      expect(res, user);
    });

    test('update() return user', () async {
      when(() => userProvider.update(
            name: 'hello',
            state: 'world',
            photo: photo,
          )).thenAnswer((_) async => user);

      final res = await userRepository.update(
        name: 'hello',
        state: 'world',
        photo: photo,
      );
      expect(res, user);
    });
  });
}
