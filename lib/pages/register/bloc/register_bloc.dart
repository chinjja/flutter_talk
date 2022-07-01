import 'package:bloc/bloc.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:talk/repos/repos.dart';

part 'register_event.dart';
part 'register_state.dart';

part 'register_bloc.g.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthRepository authRepository;
  RegisterBloc(this.authRepository) : super(const RegisterState()) {
    on<RegisterUsernameChanged>((event, emit) {
      if (event.username.length < 4) {
        emit(state.copyWith(
          username: event.username,
          usernameError: 'username.length >= 4',
        ));
      } else {
        emit(state.copyWith(
          username: event.username,
          usernameError: null,
        ));
      }
    });
    on<RegisterPasswordChanged>((event, emit) {
      if (event.password.length < 4) {
        emit(state.copyWith(
          password: event.password,
          passwordError: 'password.length >= 4',
        ));
      } else {
        emit(state.copyWith(
          password: event.password,
          passwordError: null,
        ));
      }
    });
    on<RegisterConfirmPasswordChanged>((event, emit) {
      if (event.confirmPassword != state.password) {
        emit(state.copyWith(
          confirmPassword: event.confirmPassword,
          confirmPasswordError: 'invalid confirm password',
        ));
      } else {
        emit(state.copyWith(
          confirmPassword: event.confirmPassword,
          confirmPasswordError: null,
        ));
      }
    });
    on<RegisterSubmitted>((event, emit) async {
      if (state.isValid) {
        try {
          emit(state.copyWith(submitStatus: RegisterSubmitStatus.inProgress));
          await authRepository.register(
            username: state.username,
            password: state.password,
          );
          emit(state.copyWith(submitStatus: RegisterSubmitStatus.success));
        } catch (_) {
          emit(state.copyWith(submitStatus: RegisterSubmitStatus.failure));
        }
      }
    });
  }
}
