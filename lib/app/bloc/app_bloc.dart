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
      await emit.onEach(_authRepository.onAuthChanged,
          onData: (Authentication? auth) {
        if (auth == null) {
          emit(const AppState.unauthentication());
        } else if (auth.emailVerified) {
          emit(AppState.authentication(user: auth.principal));
        } else if (!auth.emailVerified) {
          emit(AppState.emailNotVerified(user: auth.principal));
        }
      });
    });
    on<AppLogout>((event, emit) async {
      await _authRepository.logout();
    });
  }
}
