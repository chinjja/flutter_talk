import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:talk/common/common.dart';
import 'package:talk/repos/repos.dart';

part 'chat_user_list_event.dart';
part 'chat_user_list_state.dart';

part 'chat_user_list_bloc.g.dart';

class ChatUserListBloc extends Bloc<ChatUserListEvent, ChatUserListState> {
  final ChatRepository chatRepository;
  final ListenRepository listenRepository;
  final _subscription = <Unsubscribe>[];

  ChatUserListBloc(
      {required this.chatRepository, required this.listenRepository})
      : super(const ChatUserListState()) {
    on<ChatUserListStarted>((event, emit) async {
      if (state.status != FetchStatus.initial) return;
      emit(state.copyWith(
        status: FetchStatus.loading,
        chat: event.chat,
      ));

      final data = await chatRepository.getChatUsers(chat: event.chat);
      emit(state.copyWith(
        status: FetchStatus.success,
        users: data,
      ));

      _subscription
          .add(listenRepository.subscribeToChatUser(state.chat!, (event) {
        final chatUser = event.chatUser;
        if (event.isAdded) {
          add(ChatUserAdded(chatUser));
        } else if (event.isRemoved) {
          add(ChatUserAdded(chatUser));
        }
      }));
    });

    on<ChatUserListFetched>((event, emit) async {
      final chat = state.chat;
      if (chat == null) return;
      try {
        emit(state.copyWith(
          status: FetchStatus.success,
          users: await chatRepository.getChatUsers(chat: chat),
        ));
      } catch (_) {
        emit(state.copyWith(status: FetchStatus.failure));
      }
    });

    on<ChatUserListInvited>((event, emit) async {
      final chat = state.chat;
      if (chat != null) {
        await chatRepository.invite(chat: chat, users: event.users);
      }
    });

    on<ChatUserAdded>((event, emit) {
      emit(state.copyWith(users: [...state.users, event.user]));
    });

    on<ChatUserRemoved>((event, emit) {
      emit(state.copyWith(
          users: state.users.where((e) => e.user != event.user.user).toList()));
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
