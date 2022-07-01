part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

class ChatStarted extends ChatEvent {
  final Chat chat;
  final User user;

  const ChatStarted({required this.chat, required this.user});

  @override
  List<Object> get props => [chat, user];
}

class ChatMessageChanged extends ChatEvent {
  final String message;

  const ChatMessageChanged(this.message);

  @override
  List<Object> get props => [message];
}

class ChatMessageSubmitted extends ChatEvent {
  const ChatMessageSubmitted();
}

class ChatMessageReceived extends ChatEvent {
  final ChatMessage message;

  const ChatMessageReceived(this.message);

  @override
  List<Object> get props => [message];
}

class ChatMessageFetchMore extends ChatEvent {
  const ChatMessageFetchMore();
}
