part of 'chat_create_bloc.dart';

@CopyWith()
class ChatCreateState extends Equatable {
  final FormzStatus status;
  final String title;
  final String? titleError;
  final int? chatId;
  final dynamic error;

  bool get isValid => title.isNotEmpty && titleError == null;

  const ChatCreateState({
    this.status = FormzStatus.pure,
    this.title = '',
    this.titleError,
    this.chatId,
    this.error,
  });

  @override
  List<Object?> get props => [status, title, titleError, chatId, error];
}
