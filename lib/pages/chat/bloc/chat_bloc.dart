import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:talk/repos/repos.dart';

part 'chat_event.dart';
part 'chat_state.dart';

part 'chat_bloc.g.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _chatRepository;
  final _subscription = CompositeSubscription();

  ChatBloc({
    required ChatRepository chatRepository,
  })  : _chatRepository = chatRepository,
        super(const ChatState()) {
    on<ChatStarted>((event, emit) async {
      if (state.chat == null) {
        final chat = await _chatRepository.getChat(event.chatId);
        emit(state.copyWith(
          fetchStatus: ChatStatus.inProgress,
          chat: chat,
          user: event.user,
        ));
        await _chatRepository.read(chat: chat);
        final messages =
            await _chatRepository.getMessages(chat: chat, limit: 50);
        final chatUsers = await _chatRepository.getChatUsers(chat: chat);
        emit(state.copyWith(
          fetchStatus: ChatStatus.success,
          messages: messages,
          chatUsers: chatUsers,
          hasNextMessage: messages.length == 50,
        ));

        _subscription.add(
          _chatRepository.onChatMessageChanged
              .where((e) => e.isAdded)
              .map((e) => e.data)
              .where((e) => e.chat.id == chat.id)
              .listen(
            (message) {
              add(ChatMessageReceived(message));
            },
          ),
        );

        _subscription.add(
          _chatRepository.onChatUserChanged
              .where((e) => e.data.chat.id == chat.id)
              .listen(
            (data) {
              late List<ChatUser> chatUsers;
              if (data.isAdded) {
                chatUsers = [...state.chatUsers, data.data];
              } else if (data.isRemoved) {
                chatUsers = [
                  ...state.chatUsers.where((e) => e.id != data.data.id),
                ];
              } else if (data.isUpdated) {
                chatUsers = [
                  ...state.chatUsers.map(
                    (e) => e.id == data.data.id ? data.data : e,
                  ),
                ];
              } else {
                return;
              }
              add(ChatUsersChanged(chatUsers));
            },
          ),
        );
      }
    });

    on<ChatMessageChanged>((event, emit) {
      emit(state.copyWith(message: event.message));
    });

    on<ChatMessageSubmitted>((event, emit) async {
      final message = state.message.trim();
      final chat = state.chat;
      if (chat != null && message.isNotEmpty) {
        try {
          emit(state.copyWith(submitStatus: ChatStatus.inProgress));
          _chatRepository.sendMessage(
            chat: chat,
            message: message,
          );
          emit(state.copyWith(submitStatus: ChatStatus.success, message: ''));
        } catch (_) {
          emit(state.copyWith(submitStatus: ChatStatus.failure));
        }
      }
    });

    on<ChatMessageReceived>((event, emit) {
      final messages = [event.message, ...state.messages];
      emit(state.copyWith(messages: messages));

      add(const ChatReadEvent());
    });

    on<ChatMessageFetchMore>((event, emit) async {
      final chat = state.chat;
      if (chat == null) return;
      if (!state.hasNextMessage) return;

      final data = await _chatRepository.getMessages(
          chat: chat, from: state.messages.last.instant, limit: 50);
      emit(state.copyWith(
        messages: [...state.messages, ...data],
        hasNextMessage: data.length == 50,
      ));
    }, transformer: droppable());

    on<ChatReadEvent>(
      (event, emit) async {
        final chat = state.chat;
        if (chat == null) return;

        await _chatRepository.read(chat: chat);
      },
      transformer: (events, mapper) {
        return events
            .throttleTime(
              const Duration(milliseconds: 100),
              leading: false,
              trailing: true,
            )
            .flatMap((event) => mapper(event));
      },
    );

    on<ChatUsersChanged>((event, emit) {
      emit(state.copyWith(chatUsers: event.chatUsers));
    });
  }

  @override
  Future<void> close() {
    _subscription.dispose();
    return super.close();
  }
}
