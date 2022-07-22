part of 'login_bloc.dart';

@CopyWith()
class LoginState extends Equatable {
  final FormzStatus status;
  final Username username;
  final Password password;

  const LoginState({
    this.status = FormzStatus.pure,
    this.username = const Username.pure(),
    this.password = const Password.pure(),
  });

  @override
  List<Object?> get props => [
        status,
        username,
        password,
      ];
}
