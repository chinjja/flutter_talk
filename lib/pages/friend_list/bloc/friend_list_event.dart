part of 'friend_list_bloc.dart';

abstract class FriendListEvent extends Equatable {
  const FriendListEvent();

  @override
  List<Object> get props => [];
}

class FriendListListenStarted extends FriendListEvent {
  const FriendListListenStarted();
}

class FriendListUserListenStarted extends FriendListEvent {
  const FriendListUserListenStarted();
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

class FriendListUserChanged extends FriendListEvent {
  final User user;

  const FriendListUserChanged(this.user);

  @override
  List<Object> get props => [user];
}
