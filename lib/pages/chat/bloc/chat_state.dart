part of 'chat_bloc.dart';

enum ChatStatus {
  initial,
  inProgress,
  success,
  failure,
}

@CopyWith()
class ChatState extends Equatable {
  final FetchStatus fetchStatus;
  final FormzStatus submitStatus;
  final List<ChatMessage> messages;
  final List<ChatUser> chatUsers;
  final Chat? chat;
  final User? user;
  final String message;
  final bool hasNextMessage;
  final dynamic error;

  bool get isValid => message.trim().isNotEmpty;

  const ChatState({
    this.fetchStatus = FetchStatus.initial,
    this.submitStatus = FormzStatus.pure,
    this.messages = const [],
    this.chatUsers = const [],
    this.chat,
    this.user,
    this.message = '',
    this.hasNextMessage = false,
    this.error,
  });

  @override
  List<Object?> get props => [
        fetchStatus,
        submitStatus,
        messages,
        chatUsers,
        chat,
        user,
        message,
        hasNextMessage,
        error,
      ];
}
