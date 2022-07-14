part of 'chat_list_bloc.dart';

enum ChatListStatus {
  initial,
  loading,
  success,
  failure,
}

@CopyWith()
class ChatListState extends Equatable {
  final ChatListStatus status;
  final List<ChatItem> chats;

  const ChatListState({
    this.status = ChatListStatus.initial,
    this.chats = const [],
  });

  @override
  List<Object> get props => [status, chats];
}
