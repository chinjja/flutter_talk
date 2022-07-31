import 'package:bloc/bloc.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:talk/repos/repos.dart';

part 'friend_list_event.dart';
part 'friend_list_state.dart';

part 'friend_list_bloc.g.dart';

class FriendListBloc extends Bloc<FriendListEvent, FriendListState> {
  final FriendRepository _friendRepository;
  FriendListBloc({required FriendRepository chatRepository})
      : _friendRepository = chatRepository,
        super(const FriendListState()) {
    on<FriendListInited>((event, emit) async {
      if (state.status == FriendListStatus.initial) {}
      emit(state.copyWith(status: FriendListStatus.loading));
      _friendRepository.fetchFriends();
      await emit.forEach(
        _friendRepository.onFriends,
        onData: (List<Friend> friends) {
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
      try {
        await _friendRepository.addFriend(username: event.username);
      } catch (_) {
        emit(state.copyWith(addStatus: FriendListStatus.failure));
      }
    });
  }
}
