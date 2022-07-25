import 'package:bloc/bloc.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:talk/common/common.dart';
import 'package:talk/repos/repos.dart';

part 'login_event.dart';
part 'login_state.dart';

part 'login_bloc.g.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository authRepository;
  LoginBloc(this.authRepository) : super(const LoginState()) {
    on<LoginUsernameChanged>((event, emit) {
      emit(state.copyWith.username(Username.dirty(event.username)));
    });
    on<LoginPasswordChanged>((event, emit) {
      emit(state.copyWith.password(Password.dirty(event.password)));
    });
    on<LoginSubmitted>((event, emit) async {
      if (!state.isValid) {
        emit(state.copyWith(status: FormzStatus.invalid));
        return;
      }
      try {
        emit(state.copyWith(status: FormzStatus.submissionInProgress));
        await authRepository.login(
          username: state.username.value,
          password: state.password.value,
        );
        emit(state.copyWith(status: FormzStatus.submissionSuccess));
      } catch (e) {
        emit(state.copyWith(status: FormzStatus.submissionFailure));
      }
    });
  }
}
