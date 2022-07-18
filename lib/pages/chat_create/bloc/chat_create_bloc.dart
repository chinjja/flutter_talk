import 'package:bloc/bloc.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:talk/repos/repos.dart';

part 'chat_create_event.dart';
part 'chat_create_state.dart';

part 'chat_create_bloc.g.dart';

class ChatCreateBloc extends Bloc<ChatCreateEvent, ChatCreateState> {
  final ChatRepository _chatRepository;

  ChatCreateBloc({
    required ChatRepository chatRepository,
  })  : _chatRepository = chatRepository,
        super(const ChatCreateState()) {
    on<ChatCreateTitleChanged>((event, emit) {
      if (event.title.isEmpty) {
        emit(state.copyWith(title: event.title, titleError: 'title is empty'));
      } else {
        emit(state.copyWith(title: event.title, titleError: null));
      }
    });
    on<ChatCreateSubmitted>((event, emit) async {
      if (state.isValid) {
        emit(state.copyWith(status: ChatCreateSubmitStatus.inProgress));
        final chatId = await _chatRepository.createOpenChat(
          title: state.title,
        );
        emit(state.copyWith(
          status: ChatCreateSubmitStatus.success,
          chatId: chatId,
        ));
      }
    });
  }
}
