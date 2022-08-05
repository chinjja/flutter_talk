import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:talk/common/common.dart';
import 'package:talk/repos/repos.dart';

part 'profile_event.dart';
part 'profile_state.dart';

part 'profile_bloc.g.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository _userRepository;
  final ChatRepository _chatRepository;
  final ListenRepository _listenRepository;

  Unsubscribe? _unsubscribe;

  ProfileBloc({
    User? user,
    required UserRepository userRepository,
    required ChatRepository chatRepository,
    required ListenRepository listenRepository,
  })  : _userRepository = userRepository,
        _chatRepository = chatRepository,
        _listenRepository = listenRepository,
        super(ProfileState(user: user)) {
    on<ProfileStarted>((event, emit) async {
      if (state.status != FetchStatus.initial) return;

      try {
        emit(state.copyWith.status(FetchStatus.loading));
        final user = await _userRepository.get(username: event.username);
        emit(state.copyWith(
          status: FetchStatus.success,
          user: user,
        ));
      } catch (e) {
        emit(state.copyWith(
          status: FetchStatus.failure,
          error: e,
        ));
      }
      _unsubscribe = _listenRepository.subscribeToUser((event) async {
        add(ProfileUpdated(event.user));
      });
    });

    on<ProfileUpdated>((event, emit) async {
      final user = event.user;
      emit(state.copyWith(
        status: FetchStatus.success,
        user: user,
      ));
    });

    on<ProfileDirectChatClicked>((event, emit) async {
      final user = state.user;
      if (user == null) return;

      try {
        emit(state.copyWith.directChatStatus(FormzStatus.submissionInProgress));
        final chat = await _chatRepository.getDirectChat(user);
        if (chat != null) {
          emit(state.copyWith(
            directChatStatus: FormzStatus.submissionSuccess,
            directChat: chat,
          ));
          return;
        }

        final chatId = await _chatRepository.createDirectChat(other: user);
        emit(state.copyWith(
          directChatStatus: FormzStatus.submissionSuccess,
          directChat: await _chatRepository.getChat(chatId),
        ));
      } catch (e) {
        emit(state.copyWith(
          directChatStatus: FormzStatus.submissionFailure,
          error: e,
        ));
      }
    });
  }

  @override
  Future<void> close() {
    _unsubscribe?.call();
    return super.close();
  }
}
