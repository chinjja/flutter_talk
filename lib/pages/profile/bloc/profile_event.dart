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

class ProfilePhotoUpload extends ProfileEvent {
  final Uint8List photo;

  const ProfilePhotoUpload(this.photo);

  @override
  List<Object> get props => [photo];
}
