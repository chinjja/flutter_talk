// ignore_for_file: prefer_const_constructors

import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talk/common/common.dart';
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
    late ImageResizer imageResizer;

    setUp(() {
      imageResizer = MockImageResizer();
      userRepository = MockUserRepository();
      bloc = ProfileEditBloc(
        userRepository,
        user: user,
        imageResizer: imageResizer,
      );
    });

    test('init state', () {
      expect(bloc.state,
          ProfileEditState(user: user, name: user.name, state: user.state));
    });

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
      final exception = Exception('oops');

      blocTest<ProfileEditBloc, ProfileEditState>(
        'when user exists and update is success then emit success',
        build: () => bloc,
        seed: () => ProfileEditState(
            user: user, name: "name", state: "state", photo: photo),
        setUp: () {
          when(() => userRepository.update(
                name: "name",
                state: "state",
                photo: photo,
              )).thenAnswer((_) async => user);
          when(() => imageResizer.resize(photo, width: 256))
              .thenAnswer((_) async => photo);
        },
        act: (bloc) => bloc.add(ProfileEditSubmitted()),
        expect: () => [
          ProfileEditState(
            user: user,
            name: "name",
            state: "state",
            photo: photo,
            status: FormzStatus.submissionInProgress,
          ),
          ProfileEditState(
            user: user,
            name: "name",
            state: "state",
            photo: photo,
            status: FormzStatus.submissionSuccess,
          ),
        ],
      );

      blocTest<ProfileEditBloc, ProfileEditState>(
        'when user exists and update is failure then emit failure',
        build: () => bloc,
        seed: () => ProfileEditState(user: user),
        setUp: () {
          when(() => userRepository.update()).thenThrow(exception);
        },
        act: (bloc) => bloc.add(ProfileEditSubmitted()),
        expect: () => [
          ProfileEditState(
              user: user, status: FormzStatus.submissionInProgress),
          ProfileEditState(
              user: user,
              status: FormzStatus.submissionFailure,
              error: exception),
        ],
      );
    });
  });
}
