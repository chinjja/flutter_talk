part of 'profile_bloc.dart';

@CopyWith()
class ProfileState extends Equatable {
  final FetchStatus status;
  final User? user;
  const ProfileState({
    this.status = FetchStatus.initial,
    this.user,
  });

  @override
  List<Object?> get props => [status, user];
}
