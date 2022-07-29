part of 'friend_list_bloc.dart';

enum FriendListStatus {
  initial,
  loading,
  success,
  failure,
}

@CopyWith()
class FriendListState extends Equatable {
  final FriendListStatus status;
  final FriendListStatus addStatus;
  final List<Friend> friends;
  const FriendListState({
    this.status = FriendListStatus.initial,
    this.addStatus = FriendListStatus.initial,
    this.friends = const [],
  });

  @override
  List<Object> get props => [status, addStatus, friends];
}
