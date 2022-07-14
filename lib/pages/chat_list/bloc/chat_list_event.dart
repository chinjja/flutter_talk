part of 'chat_list_bloc.dart';

abstract class ChatListEvent extends Equatable {
  const ChatListEvent();

  @override
  List<Object> get props => [];
}

class ChatListStarted extends ChatListEvent {
  const ChatListStarted();
}

class ChatListFetched extends ChatListEvent {
  const ChatListFetched();
}
