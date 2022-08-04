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
  final User user;
  const FriendListState({
    this.status = FriendListStatus.initial,
    this.addStatus = FriendListStatus.initial,
    this.friends = const [],
    required this.user,
  });

  @override
  List<Object?> get props => [status, addStatus, friends, user];
}
