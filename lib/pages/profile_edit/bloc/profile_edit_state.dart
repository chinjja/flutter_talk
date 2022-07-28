part of 'profile_edit_bloc.dart';

@CopyWith()
class ProfileEditState extends Equatable {
  final FormzStatus status;
  final User user;
  final Uint8List? photo;
  final String? name;
  final String? state;
  const ProfileEditState({
    this.status = FormzStatus.pure,
    required this.user,
    this.photo,
    this.name,
    this.state,
  });

  @override
  List<Object?> get props => [status, user, photo, name, state];
}
