import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talk/app/app.dart';
import 'package:talk/pages/pages.dart';
import 'package:talk/repos/repos.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockChatRepository extends Mock implements ChatRepository {}

class MockUserRepository extends Mock implements UserRepository {}

class MockFriendRepository extends Mock implements FriendRepository {}

class MockListenRepository extends Mock implements ListenRepository {}

class MockAuthProvider extends Mock implements AuthProvider {}

class MockTokenProvider extends Mock implements TokenProvider {}

class MockUserProvider extends Mock implements UserProvider {}

class MockChatProvider extends Mock implements ChatProvider {}

class MockChatUserProvider extends Mock implements ChatUserProvider {}

class MockChatMessageProvider extends Mock implements ChatMessageProvider {}

class MockFriendProvider extends Mock implements FriendProvider {}

class MockDio extends Mock implements Dio {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class MockAppBloc extends MockBloc<AppEvent, AppState> implements AppBloc {}

class MockRegisterBloc extends MockBloc<RegisterEvent, RegisterState>
    implements RegisterBloc {}

class MockProfileEditBloc extends MockBloc<ProfileEditEvent, ProfileEditState>
    implements ProfileEditBloc {}
