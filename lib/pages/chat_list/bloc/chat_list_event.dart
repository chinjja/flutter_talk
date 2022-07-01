part of 'chat_list_bloc.dart';

abstract class ChatListEvent extends Equatable {
  const ChatListEvent();

  @override
  List<Object> get props => [];
}

class ChatListInited extends ChatListEvent {
  const ChatListInited();
}

class ChatListFetched extends ChatListEvent {
  const ChatListFetched();
}
