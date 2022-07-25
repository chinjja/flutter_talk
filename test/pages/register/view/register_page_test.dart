// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talk/common/common.dart';
import 'package:talk/pages/register/register.dart';

import '../../../mocks/mocks.dart';

void main() {
  const usernameKey = Key('registerPage_username_textField');
  const passwordKey = Key('registerPage_password_textField');
  const confirmPasswordKey = Key('registerPage_confirmPassword_textField');
  const submitKey = Key('registerPage_submit_button');

  group('RegisterPage', () {
    late RegisterBloc bloc;

    setUp(() {
      bloc = MockRegisterBloc();
      when(() => bloc.state).thenReturn(RegisterState());
    });

    group('calls', () {
      testWidgets('RegisterUsernameChanged when username is changed',
          (tester) async {
        await tester.pumpApp(bloc);
        await tester.enterText(find.byKey(usernameKey), 'user');

        verify(() => bloc.add(RegisterUsernameChanged('user'))).called(1);
      });

      testWidgets('RegisterPasswordChanged when password is changed',
          (tester) async {
        await tester.pumpApp(bloc);
        await tester.enterText(find.byKey(passwordKey), '1234');

        verify(() => bloc.add(RegisterPasswordChanged('1234'))).called(1);
      });

      testWidgets(
          'RegisterConfirmPasswordChanged when confirm password is changed',
          (tester) async {
        await tester.pumpApp(bloc);
        await tester.enterText(find.byKey(confirmPasswordKey), '1234');

        verify(() => bloc.add(RegisterConfirmPasswordChanged('1234')))
            .called(1);
      });

      testWidgets('whenAnyFieldIsInvalid_thenPressingSubmitShouldNothing',
          (tester) async {
        await tester.pumpApp(bloc);

        await tester.tap(find.byKey(submitKey));

        verifyNever(() => bloc.add(RegisterSubmitted()));
      });

      testWidgets('whenAllFieldIsValid_thenPressingSubmitShouldEmit',
          (tester) async {
        when(() => bloc.state).thenReturn(RegisterState(
          username: Username.dirty('user@user.com'),
          password: Password.dirty('1234'),
          confirmPassword: ConfirmPassword.dirty('1234', '1234'),
        ));
        await tester.pumpApp(bloc);

        await tester.tap(find.byKey(submitKey));

        verify(() => bloc.add(RegisterSubmitted())).called(1);
      });
    });

    group('renders', () {
      testWidgets('render RegisterView', (tester) async {
        await tester.pumpApp(bloc);

        expect(find.byType(RegisterView), findsOneWidget);

        final username = tester.widget(find.byKey(usernameKey)) as TextField;
        final password = tester.widget(find.byKey(passwordKey)) as TextField;
        final confirm =
            tester.widget(find.byKey(confirmPasswordKey)) as TextField;
        expect(username.decoration?.errorText, isNull);
        expect(password.decoration?.errorText, isNull);
        expect(confirm.decoration?.errorText, isNull);
      });

      testWidgets('when status is inProgress then submit button is disabled',
          (tester) async {
        when(() => bloc.state).thenReturn(RegisterState(
          status: FormzStatus.submissionInProgress,
        ));
        await tester.pumpApp(bloc);

        final button = tester.widget(find.byKey(submitKey)) as ElevatedButton;
        expect(button.enabled, false);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('when status is pure then submit button is disabled',
          (tester) async {
        await tester.pumpApp(bloc);

        final button = tester.widget(find.byKey(submitKey)) as ElevatedButton;
        expect(button.enabled, false);
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });
    });
  });
}

extension TesterX on WidgetTester {
  Future<void> pumpApp(RegisterBloc bloc) async {
    await pumpWidget(
      BlocProvider.value(
        value: bloc,
        child: MaterialApp(home: RegisterView()),
      ),
    );
  }
}
