part of 'reset_password_bloc.dart';

@CopyWith()
class ResetPasswordState extends Equatable {
  final FormzStatus status;
  final Username email;
  final dynamic error;

  const ResetPasswordState({
    this.status = FormzStatus.pure,
    this.email = const Username.pure(),
    this.error,
  });

  bool get isValid => email.valid;

  @override
  List<Object?> get props => [status, email, error];
}
