import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:talk/repos/repos.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final AuthRepository _authRepository;
  AppBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AppState.unknown()) {
    on<AppInited>((event, emit) async {
      await Future.delayed(const Duration(seconds: 1));
      await emit.onEach(_authRepository.onUserChanged, onData: (User? user) {
        if (user == null) {
          emit(const AppState.unauthentication());
        } else {
          emit(AppState.authentication(user: user));
        }
      });
    });
    on<AppLogout>((event, emit) async {
      await _authRepository.logout();
    });
  }
}
