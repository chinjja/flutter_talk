part of 'verify_email_bloc.dart';

@CopyWith()
class VerifyEmailState extends Equatable {
  final String code;
  final FetchStatus submitStatus;
  final FetchStatus sendStatus;
  final bool sendCode;
  final int seconds;
  final dynamic error;

  const VerifyEmailState({
    this.code = '',
    this.submitStatus = FetchStatus.initial,
    this.sendStatus = FetchStatus.initial,
    this.sendCode = false,
    this.seconds = 0,
    this.error,
  });

  @override
  List<Object?> get props =>
      [code, submitStatus, sendStatus, sendCode, seconds, error];
}
