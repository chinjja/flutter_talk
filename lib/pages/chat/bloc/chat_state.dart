part of 'chat_bloc.dart';

enum ChatStatus {
  initial,
  inProgress,
  success,
  failure,
}

@CopyWith()
class ChatState extends Equatable {
  final ChatStatus fetchStatus;
  final ChatStatus submitStatus;
  final List<ChatMessage> messages;
  final List<ChatUser> chatUsers;
  final Chat? chat;
  final User? user;
  final String message;
  final bool hasNextMessage;

  bool get isValid => message.trim().isNotEmpty;

  const ChatState({
    this.fetchStatus = ChatStatus.initial,
    this.submitStatus = ChatStatus.initial,
    this.messages = const [],
    this.chatUsers = const [],
    this.chat,
    this.user,
    this.message = '',
    this.hasNextMessage = false,
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
      ];
}
