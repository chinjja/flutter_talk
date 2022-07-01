part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  final int index;
  const HomeState({required this.index});

  @override
  List<Object> get props => [index];
}

class HomeFriendTab extends HomeState {
  const HomeFriendTab() : super(index: 0);
}

class HomeChatTab extends HomeState {
  const HomeChatTab() : super(index: 1);
}

class HomeMoreTab extends HomeState {
  const HomeMoreTab() : super(index: 2);
}
