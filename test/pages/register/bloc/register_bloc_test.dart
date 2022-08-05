// ignore_for_file: prefer_const_constructors

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talk/common/common.dart';
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
          RegisterState(username: Username.dirty('user')),
        ],
      );
    });

    group('RegisterPasswordChanged', () {
      blocTest<RegisterBloc, RegisterState>(
        'emits [RegisterState(password)] when event is added.',
        build: () => bloc,
        act: (bloc) => bloc.add(RegisterPasswordChanged('12')),
        expect: () => [
          RegisterState(password: Password.dirty('12')),
        ],
      );
    });

    group('RegisterConfirmPasswordChanged', () {
      blocTest<RegisterBloc, RegisterState>(
        'emits [RegisterState(confirm)] when event is added.',
        build: () => bloc,
        act: (bloc) => bloc.add(RegisterConfirmPasswordChanged('34')),
        expect: () => [
          RegisterState(confirmPassword: ConfirmPassword.dirty('', '34')),
        ],
      );
    });

    group('RegisterSubmitted', () {
      late RegisterState state;
      final exception = Exception('oops');

      setUp(() {
        state = RegisterState(
          username: Username.dirty('user@user.com'),
          password: Password.dirty('1234'),
          confirmPassword: ConfirmPassword.dirty('1234', '1234'),
        );
      });
      blocTest<RegisterBloc, RegisterState>(
        'emits [inProgress, success] when event is added.',
        build: () => bloc,
        setUp: () {
          when(() => authRepository.register(
              username: 'user@user.com',
              password: '1234')).thenAnswer((_) async => {});
        },
        seed: () => state,
        act: (bloc) => bloc.add(RegisterSubmitted()),
        expect: () => [
          state.copyWith(
            status: FormzStatus.submissionInProgress,
          ),
          state.copyWith(
            status: FormzStatus.submissionSuccess,
          ),
        ],
      );
      blocTest<RegisterBloc, RegisterState>(
        'emits [inProgress, failure] when event is added.',
        build: () => bloc,
        setUp: () {
          when(() => authRepository.register(
              username: 'user@user.com',
              password: '1234')).thenThrow(exception);
        },
        seed: () => state,
        act: (bloc) => bloc.add(RegisterSubmitted()),
        expect: () => [
          state.copyWith(
            status: FormzStatus.submissionInProgress,
          ),
          state.copyWith(
            status: FormzStatus.submissionFailure,
            error: exception,
          ),
        ],
      );

      blocTest<RegisterBloc, RegisterState>(
        'when username is invalid then emits error.',
        build: () => bloc,
        seed: () => state.copyWith.username(Username.dirty('use')),
        act: (bloc) => bloc.add(RegisterSubmitted()),
        expect: () => [
          state.copyWith(
            status: FormzStatus.invalid,
            username: Username.dirty('use'),
          ),
        ],
      );

      blocTest<RegisterBloc, RegisterState>(
        'when password is invalid then emits error.',
        build: () => bloc,
        seed: () => state.copyWith.password(Password.dirty('123')),
        act: (bloc) => bloc.add(RegisterSubmitted()),
        expect: () => [
          state.copyWith(
            status: FormzStatus.invalid,
            password: Password.dirty('123'),
          ),
        ],
      );

      blocTest<RegisterBloc, RegisterState>(
        'when confrim password is invalid then emits error.',
        build: () => bloc,
        seed: () => state.copyWith(
          confirmPassword: ConfirmPassword.dirty('', '123'),
        ),
        act: (bloc) => bloc.add(RegisterSubmitted()),
        expect: () => [
          state.copyWith(
            status: FormzStatus.invalid,
            confirmPassword: ConfirmPassword.dirty('', '123'),
          ),
        ],
      );
    });
  });
}
