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
      emit(state.copyWith.username(event.username));
    });
    on<RegisterPasswordChanged>((event, emit) {
      emit(state.copyWith.password(event.password));
    });
    on<RegisterConfirmPasswordChanged>((event, emit) {
      emit(state.copyWith.confirmPassword(event.confirmPassword));
    });
    on<RegisterSubmitted>((event, emit) async {
      final isValidUsername = state.username.trim().length >= 4;
      final isValidPassword = state.password.length >= 4;
      final isValidConfirmPassword = state.password == state.confirmPassword;
      final isValid =
          isValidUsername && isValidPassword && isValidConfirmPassword;
      if (isValid) {
        try {
          emit(state.copyWith(
            submitStatus: RegisterSubmitStatus.inProgress,
            isValidUsername: true,
            isValidPassword: true,
            isValidConfirmPassword: true,
          ));
          await authRepository.register(
            username: state.username,
            password: state.password,
          );
          emit(state.copyWith(submitStatus: RegisterSubmitStatus.success));
        } catch (_) {
          emit(state.copyWith(submitStatus: RegisterSubmitStatus.failure));
        }
      } else {
        emit(state.copyWith(
          isValidUsername: isValidUsername,
          isValidPassword: isValidPassword,
          isValidConfirmPassword: isValidConfirmPassword,
        ));
      }
    });
  }
}
