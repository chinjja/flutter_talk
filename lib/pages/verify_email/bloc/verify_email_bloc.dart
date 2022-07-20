import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:talk/common/common.dart';
import 'package:talk/repos/auth_repository/auth_repository.dart';

part 'verify_email_event.dart';
part 'verify_email_state.dart';

part 'verify_email_bloc.g.dart';

class VerifyEmailBloc extends Bloc<VerifyEmailEvent, VerifyEmailState> {
  final AuthRepository _authRepository;
  VerifyEmailBloc(this._authRepository) : super(const VerifyEmailState()) {
    on<VerifyEmailSend>((event, emit) async {
      const maxSeconds = 180;
      emit(state.copyWith.sendStatus(FetchStatus.loading));
      await _authRepository.sendCode();
      emit(state.copyWith(
        sendCode: true,
        seconds: maxSeconds,
        sendStatus: FetchStatus.success,
      ));
      await emit.onEach(
        Stream.periodic(const Duration(seconds: 1), (x) => maxSeconds - x)
            .take(maxSeconds + 1),
        onData: (int seconds) {
          add(VerifyEmailCodeTicked(seconds));
        },
      );
    }, transformer: restartable());

    on<VerifyEmailSubmitted>((event, emit) async {
      final code = state.code;
      try {
        emit(state.copyWith(submitStatus: FetchStatus.loading));

        await _authRepository.verifyCode(code);
        emit(state.copyWith(submitStatus: FetchStatus.success));
      } catch (_) {
        emit(state.copyWith(submitStatus: FetchStatus.failure));
      }
    });

    on<VerifyEmailCodeChanged>((event, emit) {
      emit(state.copyWith(code: event.code));
    });

    on<VerifyEmailCodeTicked>((event, emit) {
      emit(state.copyWith.seconds(event.seconds));
    });
  }
}
