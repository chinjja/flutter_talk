part of 'friend_list_bloc.dart';

abstract class FriendListEvent extends Equatable {
  const FriendListEvent();

  @override
  List<Object> get props => [];
}

class FriendListInited extends FriendListEvent {
  const FriendListInited();
}

class FriendAdded extends FriendListEvent {
  final String username;

  const FriendAdded(this.username);

  @override
  List<Object> get props => [username];
}

class FriendRemoved extends FriendListEvent {
  final Friend friend;

  const FriendRemoved(this.friend);

  @override
  List<Object> get props => [friend];
}
