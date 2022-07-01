part of 'app_bloc.dart';

abstract class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object> get props => [];
}

class AppInited extends AppEvent {
  const AppInited();
}

class AppLogout extends AppEvent {
  const AppLogout();
}
