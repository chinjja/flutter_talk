import 'package:bloc/bloc.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:talk/repos/repos.dart';

part 'login_event.dart';
part 'login_state.dart';

part 'login_bloc.g.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository authRepository;
  LoginBloc(this.authRepository) : super(const LoginState()) {
    on<LoginUsernameChanged>((event, emit) {
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
    on<LoginPasswordChanged>((event, emit) {
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
    on<LoginSubmitted>((event, emit) async {
      if (state.isValid) {
        try {
          emit(state.copyWith(submitStatus: LoginSubmitStatus.inProgress));
          await authRepository.login(
            username: state.username,
            password: state.password,
          );
          emit(state.copyWith(submitStatus: LoginSubmitStatus.success));
        } catch (e) {
          print(e.toString());
          emit(state.copyWith(submitStatus: LoginSubmitStatus.failure));
        }
      }
    });
  }
}
