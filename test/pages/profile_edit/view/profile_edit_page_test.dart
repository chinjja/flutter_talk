// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talk/pages/pages.dart';
import 'package:talk/repos/repos.dart';

import '../../../mocks/mocks.dart';

void main() {
  final photoButtonKey = Key('profileEditView_photo_button');
  final nameFieldKey = Key('profileEditView_name_textField');
  final stateFieldKey = Key('profileEditView_state_textField');
  final submitButtonKey = Key('profileEditView_submit_button');
  group('ProfileEditPage', () {
    final user = User(username: 'user');

    group('init', () {
      late Widget widget;
      late UserRepository userRepository;
      late StorageRepository storageRepository;

      setUp(() {
        userRepository = MockUserRepository();
        storageRepository = MockStorageRepository();
        widget = MultiRepositoryProvider(
          providers: [
            RepositoryProvider.value(value: userRepository),
            RepositoryProvider.value(value: storageRepository),
          ],
          child: MaterialApp(
            home: ProfileEditPage(user: user),
          ),
        );
      });

      testWidgets('ProfileEditStarted', (tester) async {
        await tester.pumpWidget(widget);

        expect(find.byType(ProfileEditPage), findsOneWidget);
      });
    });

    group('calls', () {
      late Widget widget;
      late ProfileEditBloc bloc;

      setUp(() {
        bloc = MockProfileEditBloc();
        widget = BlocProvider.value(
          value: bloc,
          child: MaterialApp(home: ProfileEditView()),
        );
        when(() => bloc.state).thenReturn(ProfileEditState(user: user));
      });

      testWidgets('ProfileEditNameChanged(name)', (tester) async {
        await tester.pumpWidget(widget);
        await tester.enterText(find.byKey(nameFieldKey), 'hello');

        verify(() => bloc.add(ProfileEditNameChanged('hello'))).called(1);
      });

      testWidgets('ProfileEditNameChanged(state)', (tester) async {
        await tester.pumpWidget(widget);
        await tester.enterText(find.byKey(stateFieldKey), 'world');

        verify(() => bloc.add(ProfileEditStateChanged('world'))).called(1);
      });

      testWidgets('ProfileEditSubmitted()', (tester) async {
        await tester.pumpWidget(widget);
        await tester.tap(find.byKey(submitButtonKey));

        verify(() => bloc.add(ProfileEditSubmitted())).called(1);
      });

      testWidgets('ProfileEditPickingPhoto', (tester) async {
        await tester.pumpWidget(widget);
        await tester.tap(find.byKey(photoButtonKey));

        verify(() => bloc.add(ProfileEditPickingPhoto())).called(1);
      });
    });

    group('renders', () {
      late Widget widget;
      late ProfileEditBloc bloc;

      setUp(() {
        bloc = MockProfileEditBloc();
        widget = BlocProvider.value(
          value: bloc,
          child: MaterialApp(home: ProfileEditView()),
        );
        when(() => bloc.state).thenReturn(ProfileEditState(user: user));
      });

      testWidgets('description', (tester) async {
        when(() => bloc.state).thenReturn(ProfileEditState(
          user: user,
          name: 'this is name',
          state: 'this is state',
        ));
        await tester.pumpWidget(widget);

        // expect(find.text('this is name'), findsOneWidget);
        // expect(find.text('this is state'), findsOneWidget);
      });
    });
  });
}
