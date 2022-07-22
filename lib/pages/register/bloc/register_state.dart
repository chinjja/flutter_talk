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
  final bool isValidUsername;
  final bool isValidPassword;
  final bool isValidConfirmPassword;

  const RegisterState({
    this.submitStatus = RegisterSubmitStatus.initial,
    this.username = '',
    this.password = '',
    this.confirmPassword = '',
    this.isValidUsername = false,
    this.isValidPassword = false,
    this.isValidConfirmPassword = false,
  });

  @override
  List<Object?> get props => [
        submitStatus,
        username,
        password,
        confirmPassword,
        isValidUsername,
        isValidPassword,
        isValidConfirmPassword,
      ];
}
