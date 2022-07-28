// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talk/app/app.dart';
import 'package:talk/repos/repos.dart';

import '../../mocks/mocks.dart';

void main() {
  group('App', () {
    late AppBloc bloc;

    setUp(() {
      bloc = MockAppBloc();
      when(() => bloc.state).thenReturn(AppState.unknown());
    });

    test('initial state is AppState.unknown', () {
      final authRepository = MockAuthRepository();
      expect(
        AppBloc(authRepository: authRepository).state,
        AppState.unknown(),
      );
    });

    group('calls', () {
      //
    });

    group('renders', () {
      testWidgets('when authentication is emitted then show AppView',
          (tester) async {
        final userRepository = MockUserRepository();
        final authRepository = MockAuthRepository();
        final chatRepository = MockChatRepository();
        final storageRepository = MockStorageRepository();
        when(() => authRepository.onAuthChanged).thenAnswer(
          (_) => Stream.fromIterable([
            Authentication(
              emailVerified: true,
              principal: User(
                username: 'user',
              ),
            )
          ]),
        );
        await tester.pumpWidget(App(
          userRepository: userRepository,
          authRepository: authRepository,
          chatRepository: chatRepository,
          storageRepository: storageRepository,
        ));
        expect(find.byType(AppView), findsOneWidget);
      });
    });
  });
}
