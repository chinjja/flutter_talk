part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class ProfileStarted extends ProfileEvent {
  final String username;

  const ProfileStarted(this.username);

  @override
  List<Object> get props => [username];
}

class ProfileDirectChatClicked extends ProfileEvent {
  const ProfileDirectChatClicked();
}

class ProfileUpdated extends ProfileEvent {
  final User user;

  const ProfileUpdated(this.user);

  @override
  List<Object> get props => [user];
}
