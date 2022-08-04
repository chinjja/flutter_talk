// ignore_for_file: prefer_const_constructors

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talk/app/app.dart';
import 'package:talk/repos/repos.dart';

import '../../mocks/mocks.dart';

void main() {
  group('AppBloc', () {
    late AuthRepository authRepository;
    late AppBloc bloc;

    setUp(() {
      authRepository = MockAuthRepository();
      bloc = AppBloc(authRepository: authRepository);
    });

    test('init state', () {
      expect(bloc.state, AppState.unknown);
    });

    blocTest<AppBloc, AppState>(
      'emits [unauthentication] when AppInited without auth is added.',
      build: () => bloc,
      setUp: () {
        when(() => authRepository.onAuthChanged)
            .thenAnswer((_) => Stream.value(null));
      },
      act: (bloc) => bloc.add(AppInited()),
      expect: () => [
        AppState.unauthentication,
      ],
    );

    blocTest<AppBloc, AppState>(
      'emits [authentication] when AppInited with auth is added.',
      build: () => bloc,
      setUp: () {
        when(() => authRepository.onAuthChanged).thenAnswer(
          (_) => Stream.value(
            Authentication(
              emailVerified: true,
              principal: User(username: 'user'),
            ),
          ),
        );
      },
      act: (bloc) => bloc.add(AppInited()),
      expect: () => [
        AppState.authentication,
      ],
    );

    blocTest<AppBloc, AppState>(
      'emits [emailNotVerified] when AppInited is added.',
      build: () => bloc,
      setUp: () {
        when(() => authRepository.onAuthChanged).thenAnswer(
          (_) => Stream.value(
            Authentication(
              emailVerified: false,
              principal: User(username: 'user'),
            ),
          ),
        );
      },
      act: (bloc) => bloc.add(AppInited()),
      expect: () => [
        AppState.emailNotVerified,
      ],
    );

    blocTest<AppBloc, AppState>(
      'emits [emailNotVerified] when AppInited is added.',
      build: () => bloc,
      setUp: () {
        when(() => authRepository.logout()).thenAnswer((_) async => {});
      },
      act: (bloc) => bloc.add(AppLogout()),
      verify: (_) {
        verify(() => authRepository.logout()).called(1);
        ;
      },
    );
  });
}
