part of 'profile_bloc.dart';

@CopyWith()
class ProfileState extends Equatable {
  final FetchStatus status;
  final User? user;
  final String name;
  final String state;
  final Uint8List? photo;

  const ProfileState({
    this.status = FetchStatus.initial,
    this.user,
    this.name = '',
    this.state = '',
    this.photo,
  });

  @override
  List<Object?> get props => [status, user, name, state, photo];
}
