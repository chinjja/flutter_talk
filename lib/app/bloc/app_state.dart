part of 'app_bloc.dart';

enum AppStatus {
  unknown,
  authentication,
  unauthentication,
  emailNotVerified,
}

class AppState extends Equatable {
  final AppStatus status;
  final User? user;
  const AppState._({required this.status, this.user});

  const AppState.unknown() : this._(status: AppStatus.unknown);
  const AppState.authentication({required User user})
      : this._(
          status: AppStatus.authentication,
          user: user,
        );
  const AppState.unauthentication()
      : this._(status: AppStatus.unauthentication);

  const AppState.emailNotVerified({required User user})
      : this._(
          status: AppStatus.emailNotVerified,
          user: user,
        );

  @override
  List<Object?> get props => [status, user];
}
