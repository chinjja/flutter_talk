part of 'profile_bloc.dart';

@CopyWith()
class ProfileState extends Equatable {
  final FetchStatus status;
  final User? user;
  final dynamic error;

  const ProfileState({
    this.status = FetchStatus.initial,
    this.user,
    this.error,
  });

  @override
  List<Object?> get props => [status, user, error];
}
