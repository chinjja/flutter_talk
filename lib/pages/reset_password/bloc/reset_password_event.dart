part of 'reset_password_bloc.dart';

abstract class ResetPasswordEvent extends Equatable {
  const ResetPasswordEvent();

  @override
  List<Object> get props => [];
}

class ResetPasswordEamilChanged extends ResetPasswordEvent {
  final String email;

  const ResetPasswordEamilChanged(this.email);

  @override
  List<Object> get props => [email];
}

class ResetPasswordSubmitted extends ResetPasswordEvent {
  const ResetPasswordSubmitted();
}
