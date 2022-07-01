part of 'chat_create_bloc.dart';

abstract class ChatCreateEvent extends Equatable {
  const ChatCreateEvent();

  @override
  List<Object> get props => [];
}

class ChatCreateTitleChanged extends ChatCreateEvent {
  final String title;

  const ChatCreateTitleChanged(this.title);

  @override
  List<Object> get props => [title];
}

class ChatCreateSubmitted extends ChatCreateEvent {
  const ChatCreateSubmitted();
}
