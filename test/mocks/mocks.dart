import 'package:mocktail/mocktail.dart';
import 'package:talk/repos/repos.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockAuthProvider extends Mock implements AuthProvider {}

class MockTokenProvider extends Mock implements TokenProvider {}

class MockChatProvider extends Mock implements ChatProvider {}

class MockChatUserProvider extends Mock implements ChatUserProvider {}

class MockChatMessageProvider extends Mock implements ChatMessageProvider {}

class MockFriendProvider extends Mock implements FriendProvider {}

class MockChatListenProvider extends Mock implements ChatListenProvider {}
