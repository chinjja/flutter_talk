part of 'login_bloc.dart';

enum LoginSubmitStatus {
  initial,
  inProgress,
  success,
  failure,
}

@CopyWith()
class LoginState extends Equatable {
  final LoginSubmitStatus submitStatus;
  final String username;
  final String password;
  final String? usernameError;
  final String? passwordError;
  bool get isValid =>
      username.isNotEmpty &&
      usernameError == null &&
      password.isNotEmpty &&
      passwordError == null;

  const LoginState({
    this.submitStatus = LoginSubmitStatus.initial,
    this.username = '',
    this.password = '',
    this.usernameError,
    this.passwordError,
  });

  @override
  List<Object?> get props => [
        submitStatus,
        username,
        password,
        usernameError,
        passwordError,
      ];
}
