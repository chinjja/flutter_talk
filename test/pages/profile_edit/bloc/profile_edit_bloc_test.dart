// ignore_for_file: prefer_const_constructors

import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talk/pages/pages.dart';
import 'package:talk/repos/repos.dart';

import '../../../mocks/mocks.dart';

void main() {
  group('ProfileEditBloc', () {
    final user = User(
      username: 'user',
      name: 'name',
      state: 'state',
      photoId: 'photoId',
    );
    final photo = Uint8List.fromList([0]);

    late ProfileEditBloc bloc;
    late UserRepository userRepository;
    late StorageRepository storageRepository;

    setUp(() {
      userRepository = MockUserRepository();
      storageRepository = MockStorageRepository();
      bloc = ProfileEditBloc(
        userRepository,
        storageRepository,
        user: user,
      );
    });

    test('init state', () {
      expect(bloc.state,
          ProfileEditState(user: user, name: user.name, state: user.state));
    });

    blocTest<ProfileEditBloc, ProfileEditState>(
      'emits [ProfileEditState, ProfileEditState] when ProfileEditStarted is added.',
      build: () => bloc,
      setUp: () {
        when(() => storageRepository.get(id: 'photoId'))
            .thenAnswer((_) async => photo);
      },
      act: (bloc) => bloc.add(ProfileEditStarted()),
      expect: () => [
        ProfileEditState(
            user: user, name: 'name', state: 'state', photo: photo),
      ],
    );
    blocTest<ProfileEditBloc, ProfileEditState>(
      'emits [ProfileEditState] when ProfileEditNameChanged is added.',
      build: () => bloc,
      act: (bloc) => bloc.add(ProfileEditNameChanged('user')),
      expect: () => [
        ProfileEditState(user: user, name: 'user', state: 'state'),
      ],
    );

    blocTest<ProfileEditBloc, ProfileEditState>(
      'emits [ProfileEditState] when ProfileEditStateChanged is added.',
      build: () => bloc,
      act: (bloc) => bloc.add(ProfileEditStateChanged('hello')),
      expect: () => [
        ProfileEditState(user: user, name: 'name', state: 'hello'),
      ],
    );

    blocTest<ProfileEditBloc, ProfileEditState>(
      'emits [ProfileEditState] when MyEvent is added.',
      build: () => bloc,
      act: (bloc) => bloc.add(ProfileEditPhotoChanged(Uint8List.fromList([0]))),
      expect: () => [
        ProfileEditState(
            user: user,
            name: 'name',
            state: 'state',
            photo: Uint8List.fromList([0])),
      ],
    );

    group('ProfileEditSubmitted', () {
      blocTest<ProfileEditBloc, ProfileEditState>(
        'when user exists and update is success then emit success',
        build: () => bloc,
        seed: () => ProfileEditState(user: user),
        setUp: () {
          when(() => userRepository.update()).thenAnswer((_) async => user);
        },
        act: (bloc) => bloc.add(ProfileEditSubmitted()),
        expect: () => [
          ProfileEditState(
              user: user, status: FormzStatus.submissionInProgress),
          ProfileEditState(user: user, status: FormzStatus.submissionSuccess),
        ],
      );

      blocTest<ProfileEditBloc, ProfileEditState>(
        'when user exists and update is failure then emit failure',
        build: () => bloc,
        seed: () => ProfileEditState(user: user),
        setUp: () {
          when(() => userRepository.update()).thenThrow(Exception('oops'));
        },
        act: (bloc) => bloc.add(ProfileEditSubmitted()),
        expect: () => [
          ProfileEditState(
              user: user, status: FormzStatus.submissionInProgress),
          ProfileEditState(user: user, status: FormzStatus.submissionFailure),
        ],
      );
    });
  });
}
