part of 'register_bloc.dart';

enum RegisterSubmitStatus {
  initial,
  inProgress,
  success,
  failure,
}

@CopyWith()
class RegisterState extends Equatable {
  final RegisterSubmitStatus submitStatus;
  final String username;
  final String password;
  final String confirmPassword;
  final String? usernameError;
  final String? passwordError;
  final String? confirmPasswordError;
  bool get isValid =>
      username.isNotEmpty &&
      usernameError == null &&
      password.isNotEmpty &&
      passwordError == null &&
      confirmPassword.isNotEmpty &&
      confirmPasswordError == null;

  const RegisterState({
    this.submitStatus = RegisterSubmitStatus.initial,
    this.username = '',
    this.password = '',
    this.confirmPassword = '',
    this.usernameError,
    this.passwordError,
    this.confirmPasswordError,
  });

  @override
  List<Object?> get props => [
        submitStatus,
        username,
        password,
        confirmPassword,
        usernameError,
        passwordError,
        confirmPasswordError,
      ];
}
