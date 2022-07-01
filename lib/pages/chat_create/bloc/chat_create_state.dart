part of 'chat_create_bloc.dart';

enum ChatCreateSubmitStatus {
  initial,
  inProgress,
  success,
  failure,
}

@CopyWith()
class ChatCreateState extends Equatable {
  final ChatCreateSubmitStatus status;
  final String title;
  final String? titleError;
  bool get isValid => title.isNotEmpty && titleError == null;

  const ChatCreateState({
    this.status = ChatCreateSubmitStatus.initial,
    this.title = '',
    this.titleError,
  });

  @override
  List<Object?> get props => [status, title, titleError];
}
