import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:rxdart/rxdart.dart';
import 'package:talk/common/common.dart';
import 'package:talk/repos/repos.dart';

part 'chat_event.dart';
part 'chat_state.dart';

part 'chat_bloc.g.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _chatRepository;
  final ListenRepository _listenRepository;
  final _subscription = <Unsubscribe>[];

  ChatBloc({
    required ChatRepository chatRepository,
    required ListenRepository listenRepository,
  })  : _chatRepository = chatRepository,
        _listenRepository = listenRepository,
        super(const ChatState()) {
    on<ChatStarted>((event, emit) async {
      if (state.chat == null) {
        try {
          final chat = await _chatRepository.getChat(event.chatId);
          emit(state.copyWith(
            fetchStatus: FetchStatus.loading,
            chat: chat,
            user: event.user,
          ));
          await _chatRepository.read(chat: chat);
          final messages =
              await _chatRepository.getMessages(chat: chat, limit: 50);
          final chatUsers = await _chatRepository.getChatUsers(chat: chat);
          emit(state.copyWith(
            fetchStatus: FetchStatus.success,
            messages: messages,
            chatUsers: chatUsers,
            hasNextMessage: messages.length == 50,
          ));

          _subscription.add(
            _listenRepository.subscribeToChat(
              (event) {
                if (event.chat.id == state.chat?.id && event.isRemoved) {
                  add(const ChatRemoved());
                }
              },
            ),
          );

          _subscription.add(
            _listenRepository.subscribeToChatMessage(
              chat,
              (event) {
                if (event.isAdded) {
                  add(ChatMessageReceived(event.message));
                }
              },
            ),
          );

          _subscription.add(
            _listenRepository.subscribeToChatUser(
              chat,
              (data) {
                final chatUser = data.chatUser;
                late List<ChatUser> chatUsers;
                if (data.isAdded) {
                  chatUsers = [...state.chatUsers, chatUser];
                } else if (data.isRemoved) {
                  chatUsers = [
                    ...state.chatUsers.where((e) => e.user != chatUser.user),
                  ];
                } else if (data.isUpdated) {
                  chatUsers = [
                    ...state.chatUsers.map(
                      (e) => e.user == chatUser.user ? chatUser : e,
                    ),
                  ];
                } else {
                  return;
                }
                add(ChatUsersChanged(chatUsers));
              },
            ),
          );
        } catch (_) {
          add(const ChatRemoved());
        }
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
          emit(state.copyWith(submitStatus: FormzStatus.submissionInProgress));
          _chatRepository.sendMessage(
            chat: chat,
            message: message,
          );
          emit(state.copyWith(
            submitStatus: FormzStatus.submissionSuccess,
            message: '',
          ));
        } catch (e) {
          emit(state.copyWith(
            submitStatus: FormzStatus.submissionFailure,
            error: e,
          ));
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

    on<ChatRemoved>((event, emit) {
      emit(state.copyWith.removed(true));
    });
  }

  @override
  Future<void> close() {
    for (final un in _subscription) {
      un();
    }
    _subscription.clear();
    return super.close();
  }
}
