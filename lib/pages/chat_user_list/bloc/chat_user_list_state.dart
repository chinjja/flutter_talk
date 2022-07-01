part of 'chat_user_list_bloc.dart';

@CopyWith()
class ChatUserListState extends Equatable {
  const ChatUserListState({
    this.chat,
    this.status = FetchStatus.initial,
    this.users = const [],
    this.hasMoreUser = false,
  });

  final Chat? chat;
  final FetchStatus status;
  final List<ChatUser> users;
  final bool hasMoreUser;

  @override
  List<Object?> get props => [chat, status, users, hasMoreUser];
}
