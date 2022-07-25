import 'package:bloc/bloc.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:talk/common/common.dart';
import 'package:talk/repos/repos.dart';

part 'register_event.dart';
part 'register_state.dart';

part 'register_bloc.g.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthRepository authRepository;
  RegisterBloc(this.authRepository) : super(const RegisterState()) {
    on<RegisterUsernameChanged>((event, emit) {
      emit(state.copyWith.username(Username.dirty(event.username)));
    });
    on<RegisterPasswordChanged>((event, emit) {
      emit(state.copyWith.password(Password.dirty(event.password)));
    });
    on<RegisterConfirmPasswordChanged>((event, emit) {
      emit(state.copyWith.confirmPassword(
          ConfirmPassword.dirty(state.password.value, event.confirmPassword)));
    });
    on<RegisterSubmitted>((event, emit) async {
      if (!state.isValid) {
        emit(state.copyWith(status: FormzStatus.invalid));
        return;
      }
      try {
        emit(state.copyWith(
          status: FormzStatus.submissionInProgress,
        ));
        await authRepository.register(
          username: state.username.value,
          password: state.password.value,
        );
        emit(state.copyWith(status: FormzStatus.submissionSuccess));
      } catch (_) {
        emit(state.copyWith(status: FormzStatus.submissionFailure));
      }
    });
  }
}
