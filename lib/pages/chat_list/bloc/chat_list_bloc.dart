import 'package:bloc/bloc.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:talk/repos/repos.dart';

part 'chat_list_event.dart';
part 'chat_list_state.dart';

part 'chat_list_bloc.g.dart';

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final ChatRepository _chatRepository;
  ChatListBloc({
    required ChatRepository chatRepository,
  })  : _chatRepository = chatRepository,
        super(const ChatListState()) {
    on<ChatListStarted>((event, emit) async {
      emit(state.copyWith(status: ChatListStatus.loading));
      add(const ChatListFetched());
      await emit.forEach(_chatRepository.onJoinedChatsChanged,
          onData: (List<ChatItem> data) {
        return state.copyWith(status: ChatListStatus.success, chats: data);
      });
    });
    on<ChatListFetched>((event, emit) async {
      await _chatRepository.fetchJoinedChats();
    });

    on<ChatListLeaved>((event, emit) async {
      await _chatRepository.leave(chat: event.chat);
    });
  }
}
