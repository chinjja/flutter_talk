import 'package:bloc/bloc.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
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
        try {
          emit(state.copyWith(status: FormzStatus.submissionInProgress));
          final chatId = await _chatRepository.createOpenChat(
            title: state.title,
          );
          emit(state.copyWith(
            status: FormzStatus.submissionSuccess,
            chatId: chatId,
          ));
        } catch (e) {
          emit(state.copyWith(
            status: FormzStatus.submissionFailure,
            error: e,
          ));
        }
      }
    });
  }
}
