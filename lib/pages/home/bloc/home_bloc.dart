import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeFriendTab()) {
    on<HomeTapped>((event, emit) {
      switch (event.index) {
        case 0:
          emit(const HomeFriendTab());
          break;
        case 1:
          emit(const HomeChatTab());
          break;
        case 2:
          emit(const HomeMoreTab());
          break;
      }
    });
  }
}
