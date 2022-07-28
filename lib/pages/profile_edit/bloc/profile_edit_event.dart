part of 'profile_edit_bloc.dart';

abstract class ProfileEditEvent extends Equatable {
  const ProfileEditEvent();

  @override
  List<Object> get props => [];
}

class ProfileEditStarted extends ProfileEditEvent {
  const ProfileEditStarted();
}

class ProfileEditPickingPhoto extends ProfileEditEvent {
  const ProfileEditPickingPhoto();
}

class ProfileEditPhotoChanged extends ProfileEditEvent {
  final Uint8List photo;

  const ProfileEditPhotoChanged(this.photo);

  @override
  List<Object> get props => [photo];
}

class ProfileEditNameChanged extends ProfileEditEvent {
  final String name;

  const ProfileEditNameChanged(this.name);

  @override
  List<Object> get props => [name];
}

class ProfileEditStateChanged extends ProfileEditEvent {
  final String state;

  const ProfileEditStateChanged(this.state);

  @override
  List<Object> get props => [state];
}

class ProfileEditSubmitted extends ProfileEditEvent {
  const ProfileEditSubmitted();
}
