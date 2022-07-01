import 'package:bloc/bloc.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:talk/repos/repos.dart';

part 'friend_list_event.dart';
part 'friend_list_state.dart';

part 'friend_list_bloc.g.dart';

class FriendListBloc extends Bloc<FriendListEvent, FriendListState> {
  final ChatRepository _chatRepository;
  FriendListBloc({required ChatRepository chatRepository})
      : _chatRepository = chatRepository,
        super(const FriendListState()) {
    on<FriendListInited>((event, emit) async {
      if (state.status == FriendListStatus.initial) {}
      emit(state.copyWith(status: FriendListStatus.loading));
      _chatRepository.fetchFriends();
      await emit.forEach(
        _chatRepository.onFriendsChanged,
        onData: (List<User> friends) {
          return state.copyWith(
            status: FriendListStatus.success,
            addStatus: FriendListStatus.success,
            friends: friends,
          );
        },
      );
    });

    on<FriendAdded>((event, emit) async {
      emit(state.copyWith(addStatus: FriendListStatus.loading));
      await Future.delayed(const Duration(seconds: 1));
      try {
        await _chatRepository.addFriend(username: event.username);
      } catch (_) {
        emit(state.copyWith(addStatus: FriendListStatus.failure));
      }
    });
  }
}
