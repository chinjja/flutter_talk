part of 'verify_email_bloc.dart';

abstract class VerifyEmailEvent extends Equatable {
  const VerifyEmailEvent();

  @override
  List<Object> get props => [];
}

class VerifyEmailSubmitted extends VerifyEmailEvent {
  const VerifyEmailSubmitted();
}

class VerifyEmailSend extends VerifyEmailEvent {
  const VerifyEmailSend();
}

class VerifyEmailCodeChanged extends VerifyEmailEvent {
  final String code;

  const VerifyEmailCodeChanged(this.code);

  @override
  List<Object> get props => [code];
}

class VerifyEmailCodeTicked extends VerifyEmailEvent {
  final int seconds;

  const VerifyEmailCodeTicked(this.seconds);

  @override
  List<Object> get props => [seconds];
}
