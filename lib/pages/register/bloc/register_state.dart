part of 'register_bloc.dart';

@CopyWith()
class RegisterState extends Equatable {
  final FormzStatus status;
  final Username username;
  final Password password;
  final ConfirmPassword confirmPassword;

  const RegisterState({
    this.status = FormzStatus.pure,
    this.username = const Username.pure(),
    this.password = const Password.pure(),
    this.confirmPassword = const ConfirmPassword.pure(),
  });

  bool get isValid => username.valid && password.valid && confirmPassword.valid;

  @override
  List<Object?> get props => [
        status,
        username,
        password,
        confirmPassword,
      ];
}
