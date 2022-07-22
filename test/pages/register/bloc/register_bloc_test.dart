// ignore_for_file: prefer_const_constructors

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talk/pages/register/bloc/register_bloc.dart';
import 'package:talk/repos/repos.dart';

import '../../../mocks/mocks.dart';

void main() {
  group('RegisterBloc', () {
    late AuthRepository authRepository;
    late RegisterBloc bloc;

    setUp(() {
      authRepository = MockAuthRepository();
      bloc = RegisterBloc(authRepository);
    });

    test('initial state', () {
      expect(bloc.state, RegisterState());
    });

    group('RegisterUsernameChanged', () {
      blocTest<RegisterBloc, RegisterState>(
        'emits [RegisterState(username)] when event is added.',
        build: () => bloc,
        act: (bloc) => bloc.add(RegisterUsernameChanged('user')),
        expect: () => [
          RegisterState(username: 'user'),
        ],
      );
    });

    group('RegisterPasswordChanged', () {
      blocTest<RegisterBloc, RegisterState>(
        'emits [RegisterState(password)] when event is added.',
        build: () => bloc,
        act: (bloc) => bloc.add(RegisterPasswordChanged('12')),
        expect: () => [
          RegisterState(password: '12'),
        ],
      );
    });

    group('RegisterConfirmPasswordChanged', () {
      blocTest<RegisterBloc, RegisterState>(
        'emits [RegisterState(confirm)] when event is added.',
        build: () => bloc,
        act: (bloc) => bloc.add(RegisterConfirmPasswordChanged('34')),
        expect: () => [
          RegisterState(confirmPassword: '34'),
        ],
      );
    });

    group('RegisterSubmitted', () {
      final state = RegisterState(
        username: 'user',
        password: '1234',
        confirmPassword: '1234',
      );
      blocTest<RegisterBloc, RegisterState>(
        'emits [inProgress, success] when event is added.',
        build: () => bloc,
        setUp: () {
          when(() =>
                  authRepository.register(username: 'user', password: '1234'))
              .thenAnswer((_) async => {});
        },
        seed: () => state,
        act: (bloc) => bloc.add(RegisterSubmitted()),
        expect: () => [
          state.copyWith(
            isValidUsername: true,
            isValidPassword: true,
            isValidConfirmPassword: true,
            submitStatus: RegisterSubmitStatus.inProgress,
          ),
          state.copyWith(
            isValidUsername: true,
            isValidPassword: true,
            isValidConfirmPassword: true,
            submitStatus: RegisterSubmitStatus.success,
          ),
        ],
      );
      blocTest<RegisterBloc, RegisterState>(
        'emits [inProgress, failure] when event is added.',
        build: () => bloc,
        setUp: () {
          when(() =>
                  authRepository.register(username: 'user', password: '1234'))
              .thenThrow(Exception('oops'));
        },
        seed: () => state,
        act: (bloc) => bloc.add(RegisterSubmitted()),
        expect: () => [
          state.copyWith(
            isValidUsername: true,
            isValidPassword: true,
            isValidConfirmPassword: true,
            submitStatus: RegisterSubmitStatus.inProgress,
          ),
          state.copyWith(
            isValidUsername: true,
            isValidPassword: true,
            isValidConfirmPassword: true,
            submitStatus: RegisterSubmitStatus.failure,
          ),
        ],
      );

      blocTest<RegisterBloc, RegisterState>(
        'when username is invalid then emits error.',
        build: () => bloc,
        seed: () => state.copyWith.username('use'),
        act: (bloc) => bloc.add(RegisterSubmitted()),
        expect: () => [
          state.copyWith(
            username: 'use',
            isValidPassword: true,
            isValidConfirmPassword: true,
          ),
        ],
      );

      blocTest<RegisterBloc, RegisterState>(
        'when password is invalid then emits error.',
        build: () => bloc,
        seed: () => state.copyWith.password('123'),
        act: (bloc) => bloc.add(RegisterSubmitted()),
        expect: () => [
          state.copyWith(
            password: '123',
            isValidUsername: true,
          ),
        ],
      );

      blocTest<RegisterBloc, RegisterState>(
        'when confrim password is invalid then emits error.',
        build: () => bloc,
        seed: () => state.copyWith(
          confirmPassword: '123',
        ),
        act: (bloc) => bloc.add(RegisterSubmitted()),
        expect: () => [
          state.copyWith(
            confirmPassword: '123',
            isValidUsername: true,
            isValidPassword: true,
          ),
        ],
      );
    });
  });
}
