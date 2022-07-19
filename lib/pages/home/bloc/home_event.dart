part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class HomeTapped extends HomeEvent {
  final int index;
  const HomeTapped(this.index);

  @override
  List<Object> get props => [index];
}
