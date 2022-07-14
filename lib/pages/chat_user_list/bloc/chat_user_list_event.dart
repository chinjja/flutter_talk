part of 'chat_user_list_bloc.dart';

abstract class ChatUserListEvent extends Equatable {
  const ChatUserListEvent();

  @override
  List<Object> get props => [];
}

class ChatUserListStarted extends ChatUserListEvent {
  final Chat chat;
  const ChatUserListStarted({required this.chat});

  @override
  List<Object> get props => [chat];
}

class ChatUserListFetched extends ChatUserListEvent {
  const ChatUserListFetched();
}

class ChatUserAdded extends ChatUserListEvent {
  final ChatUser user;

  const ChatUserAdded(this.user);

  @override
  List<Object> get props => [user];
}

class ChatUserRemoved extends ChatUserListEvent {
  final ChatUser user;

  const ChatUserRemoved(this.user);

  @override
  List<Object> get props => [user];
}

class ChatUserListInvited extends ChatUserListEvent {
  final List<User> users;

  const ChatUserListInvited(this.users);

  @override
  List<Object> get props => [users];
}
