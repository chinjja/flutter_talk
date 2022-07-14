import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:talk/common/common.dart';
import 'package:talk/repos/repos.dart';

part 'chat_user_list_event.dart';
part 'chat_user_list_state.dart';

part 'chat_user_list_bloc.g.dart';

class ChatUserListBloc extends Bloc<ChatUserListEvent, ChatUserListState> {
  final ChatRepository _chatRepository;
  final _subscription = CompositeSubscription();

  ChatUserListBloc(this._chatRepository) : super(const ChatUserListState()) {
    on<ChatUserListStarted>((event, emit) async {
      if (state.status != FetchStatus.initial) return;

      emit(state.copyWith(
        status: FetchStatus.loading,
        chat: event.chat,
      ));

      final data = await _chatRepository.getChatUsers(chat: event.chat);
      emit(state.copyWith(
        status: FetchStatus.success,
        users: data,
      ));

      _subscription.add(_chatRepository.onChatUserChanged.listen((event) {
        final chatUser = event.data;
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
          users: await _chatRepository.getChatUsers(chat: chat),
        ));
      } catch (_) {
        emit(state.copyWith(status: FetchStatus.failure));
      }
    });

    on<ChatUserListInvited>((event, emit) async {
      final chat = state.chat;
      if (chat != null) {
        await _chatRepository.invite(chat: chat, users: event.users);
      }
    });

    on<ChatUserAdded>((event, emit) {
      emit(state.copyWith(users: [...state.users, event.user]));
    });

    on<ChatUserRemoved>((event, emit) {
      emit(state.copyWith(
          users: state.users.where((e) => e.id != event.user.id).toList()));
    });
  }

  @override
  Future<void> close() {
    _subscription.dispose();
    return super.close();
  }
}
