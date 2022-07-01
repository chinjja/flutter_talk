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

class ChatUserListAdded extends ChatUserListEvent {
  final List<ChatUser> users;

  const ChatUserListAdded(this.users);

  @override
  List<Object> get props => [users];
}

class ChatUserListRemoved extends ChatUserListEvent {
  final List<ChatUser> users;

  const ChatUserListRemoved(this.users);

  @override
  List<Object> get props => [users];
}

class ChatUserListInvited extends ChatUserListEvent {
  final List<User> users;

  const ChatUserListInvited(this.users);

  @override
  List<Object> get props => [users];
}
