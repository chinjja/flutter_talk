import 'package:bloc/bloc.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:talk/common/common.dart';
import 'package:talk/repos/auth_repository/auth_repository.dart';

part 'reset_password_event.dart';
part 'reset_password_state.dart';

part 'reset_password_bloc.g.dart';

class ResetPasswordBloc extends Bloc<ResetPasswordEvent, ResetPasswordState> {
  final AuthRepository _authRepository;
  ResetPasswordBloc(this._authRepository) : super(const ResetPasswordState()) {
    on<ResetPasswordEamilChanged>((event, emit) {
      emit(state.copyWith(
        email: Username.dirty(event.email),
        status: state.isValid ? FormzStatus.valid : FormzStatus.invalid,
      ));
    });

    on<ResetPasswordSubmitted>((event, emit) async {
      if (state.email.valid) {
        try {
          emit(state.copyWith.status(FormzStatus.submissionInProgress));
          await _authRepository.sendResetPassword(state.email.value);

          emit(state.copyWith.status(FormzStatus.submissionSuccess));
        } catch (_) {
          emit(state.copyWith.status(FormzStatus.submissionFailure));
        }
      } else {
        emit(state.copyWith.status(FormzStatus.invalid));
      }
    });
  }
}
