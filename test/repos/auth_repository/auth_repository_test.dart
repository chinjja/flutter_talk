// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talk/repos/repos.dart';

import '../../mocks/mocks.dart';

void main() {
  group('AuthRepository', () {
    const token = Token(accessToken: 'a', refreshToken: 'b');
    const user = User(username: "user");
    const authentication = Authentication(principal: user, emailVerified: true);

    late AuthProvider authProvider;
    late TokenProvider tokenProvider;
    late UserProvider userProvider;
    late ListenRepository listenRepository;
    late AuthRepository authRepository;

    setUp(() {
      authProvider = MockAuthProvider();
      tokenProvider = MockTokenProvider();
      userProvider = MockUserProvider();
      listenRepository = MockListenRepository();
      authRepository = AuthRepository(
        authProvider,
        tokenProvider,
        userProvider,
        listenRepository,
      );
      when(() => listenRepository.onConnectedUser)
          .thenAnswer((_) => Stream.value(null));
    });

    group('init()', () {
      test('when token is not exists then emits null', () async {
        when(() => tokenProvider.read()).thenAnswer((_) async => null);
        when(() => tokenProvider.clear()).thenAnswer((_) => Future.value());

        authRepository.init();

        await expectLater(authRepository.onAuthChanged, emits(null));
        verify(() => tokenProvider.clear()).called(1);
        verifyNever(() => authProvider.isVerified());
      });

      test('when refresh token is expired then emits null', () async {
        when(() => tokenProvider.read()).thenAnswer((_) async => token);
        when(() => tokenProvider.isExpired(token.refreshToken))
            .thenReturn(true);
        when(() => tokenProvider.clear()).thenAnswer((_) => Future.value());

        authRepository.init();

        await expectLater(authRepository.onAuthChanged, emits(null));
        verify(() => tokenProvider.clear()).called(1);
        verifyNever(() => authProvider.isVerified());
      });

      test('when user is received then emits authentication', () async {
        when(() => tokenProvider.read()).thenAnswer((_) async => token);
        when(() => tokenProvider.isExpired(token.refreshToken))
            .thenReturn(false);
        when(() => tokenProvider.decode(token.accessToken))
            .thenReturn({'sub': 'user'});
        when(() => userProvider.get(username: 'user'))
            .thenAnswer((_) async => user);

        authRepository.init();

        await expectLater(authRepository.onAuthChanged, emits(authentication));

        verifyNever(() => tokenProvider.clear());
      });

      test('when get user is failed then emits null', () async {
        when(() => tokenProvider.read()).thenAnswer((_) async => token);
        when(() => tokenProvider.isExpired(token.refreshToken))
            .thenReturn(false);
        when(() => tokenProvider.decode(token.accessToken))
            .thenReturn({'sub': 'user'});
        when(() => tokenProvider.clear()).thenAnswer((_) async => {});
        when(() => userProvider.get(username: 'user'))
            .thenThrow(Exception('oops'));

        authRepository.init();

        await expectLater(authRepository.onAuthChanged, emits(null));

        verify(() => tokenProvider.clear()).called(1);
      });
    });

    group('register()', () {
      test(
          'when username and password is passed then register() should be called',
          () async {
        when(() => authProvider.register(
              username: 'user',
              password: '1234',
            )).thenAnswer((_) async => {});

        await authRepository.register(
          username: 'user',
          password: '1234',
        );
        verify(() => authProvider.register(
              username: 'user',
              password: '1234',
            )).called(1);
      });
    });

    group('login()', () {
      test('when username and password is passed then emits authentication',
          () async {
        when(() => authProvider.login(
              username: 'user',
              password: '1234',
            )).thenAnswer((_) async => token);
        when(() => authProvider.isVerified()).thenAnswer((_) async => true);
        when(() => tokenProvider.write(token)).thenAnswer((_) async => {});
        when(() => userProvider.get(username: 'user'))
            .thenAnswer((_) async => user);

        authRepository.login(
          username: 'user',
          password: '1234',
        );

        await expectLater(authRepository.onAuthChanged, emits(authentication));
        expect(authRepository.user, User(username: 'user'));

        verify(() => authProvider.login(
              username: 'user',
              password: '1234',
            )).called(1);
        verify(() => tokenProvider.write(token)).called(1);
      });
    });

    group('logout()', () {
      test('when logout() is success then should emit null', () async {
        when(() => authProvider.logout()).thenAnswer((_) async => {});
        when(() => tokenProvider.clear()).thenAnswer((_) async => {});

        authRepository.logout();

        await expectLater(authRepository.onAuthChanged, emits(null));
        expect(authRepository.user, isNull);

        verify(() => authProvider.logout()).called(1);
        verify(() => tokenProvider.clear()).called(1);
      });
      test('when logout() is throw then should emit null', () async {
        when(() => authProvider.logout()).thenThrow(Exception('oops'));
        when(() => tokenProvider.clear()).thenAnswer((_) async => {});

        authRepository.logout();

        await expectLater(authRepository.onAuthChanged, emits(null));
        expect(authRepository.user, isNull);

        verify(() => tokenProvider.clear()).called(1);
      });
      test('when clear() is throw then should emit null', () async {
        when(() => authProvider.logout()).thenThrow(Exception('oops'));

        authRepository.logout();

        await expectLater(authRepository.onAuthChanged, emits(null));
        expect(authRepository.user, isNull);
      });
    });

    group('sendCode()', () {
      test('test name', () async {
        when(() => authProvider.sendCode()).thenAnswer((_) async => {});
        await authRepository.sendCode();
        verify(() => authProvider.sendCode()).called(1);
      });
    });

    group('verifyCode()', () {
      test('when verifyCode() is success then should success', () async {
        when(() => authProvider.verifyCode("1234")).thenAnswer((_) async => {});
        when(() => tokenProvider.read()).thenAnswer((_) async => token);
        when(() => tokenProvider.decode(token.accessToken))
            .thenReturn({'sub': 'user'});
        authRepository.verifyCode("1234");
        when(() => userProvider.get(username: 'user'))
            .thenAnswer((_) async => user);

        await expectLater(authRepository.onAuthChanged, emits(authentication));
        verify(() => authProvider.verifyCode("1234")).called(1);
      });
    });

    group('sendResetPassword()', () {
      test('when email is passed then shoudl success', () async {
        when(() => authProvider.sendResetPassword('user@user.com'))
            .thenAnswer((_) => Future.value());

        await authRepository.sendResetPassword('user@user.com');
        verify(() => authProvider.sendResetPassword('user@user.com')).called(1);
      });
    });
  });
}
