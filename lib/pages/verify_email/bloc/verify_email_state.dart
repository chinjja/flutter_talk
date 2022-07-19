part of 'verify_email_bloc.dart';

@CopyWith()
class VerifyEmailState extends Equatable {
  final String code;
  final FetchStatus submitStatus;
  final FetchStatus sendStatus;
  final bool sendCode;
  final int seconds;

  const VerifyEmailState({
    this.code = '',
    this.submitStatus = FetchStatus.initial,
    this.sendStatus = FetchStatus.initial,
    this.sendCode = false,
    this.seconds = 0,
  });

  @override
  List<Object> get props => [code, submitStatus, sendStatus, sendCode, seconds];
}
