part of 'reset_password_bloc.dart';

@CopyWith()
class ResetPasswordState extends Equatable {
  final FormzStatus status;
  final Username email;
  const ResetPasswordState({
    this.status = FormzStatus.pure,
    this.email = const Username.pure(),
  });

  bool get isValid => email.valid;

  @override
  List<Object> get props => [status, email];
}
