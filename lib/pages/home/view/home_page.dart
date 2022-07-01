import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talk/pages/chat_list/chat_list.dart';
import 'package:talk/pages/friend_list/friend_list.dart';
import 'package:talk/pages/settings/settings.dart';

import '../home.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 500) {
          return Scaffold(
            body: Row(
              children: const [
                _Rail(),
                Expanded(child: _Body()),
              ],
            ),
          );
        } else {
          return const Scaffold(
            body: _Body(),
            bottomNavigationBar: _BottomBar(),
          );
        }
      },
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeChatTab) {
          return const ChatListPage();
        }
        if (state is HomeFriendTab) {
          return const FriendListPage();
        }
        if (state is HomeMoreTab) {
          return const SettingsPage();
        }
        return const SizedBox();
      },
    );
  }
}

class _Rail extends StatelessWidget {
  const _Rail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return NavigationRail(
          selectedIndex: state.index,
          labelType: NavigationRailLabelType.all,
          destinations: const [
            NavigationRailDestination(
              icon: Icon(Icons.person),
              label: Text('Friend'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.chat),
              label: Text('Chat'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.settings),
              label: Text('Settings'),
            ),
          ],
          onDestinationSelected: (index) {
            context.read<HomeBloc>().add(HomeTapped(index));
          },
        );
      },
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return BottomNavigationBar(
          currentIndex: state.index,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Friend',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          onTap: (index) {
            context.read<HomeBloc>().add(HomeTapped(index));
          },
        );
      },
    );
  }
}
