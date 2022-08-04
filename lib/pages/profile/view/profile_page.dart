import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:talk/common/common.dart';
import 'package:talk/repos/repos.dart';

import '../profile.dart';

class ProfilePage extends StatelessWidget {
  final String username;

  const ProfilePage({Key? key, required this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(
        context.read<UserRepository>(),
        context.read<ListenRepository>(),
      )..add(ProfileStarted(username)),
      child: const ProfileView(),
    );
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            actions: const [
              IconButton(
                icon: Icon(Icons.money),
                onPressed: null,
              ),
              IconButton(
                icon: Icon(Icons.star),
                onPressed: null,
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                _ProfilePhoto(),
                _NameText(),
                SizedBox(height: 8),
                _StateText(),
                SizedBox(height: 8),
                Divider(),
                SizedBox(height: 8),
                _BottomActions(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProfilePhoto extends StatelessWidget {
  const _ProfilePhoto({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      height: 96,
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          return UserAvatar(state.user);
        },
      ),
    );
  }
}

class _NameText extends StatelessWidget {
  const _NameText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final user = state.user;
        return Text(user?.name ?? user?.username ?? '');
      },
    );
  }
}

class _StateText extends StatelessWidget {
  const _StateText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final user = state.user;
        return Text(user?.state ?? '');
      },
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final isAuth = context.isAuth(state.user);
        return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _tap(Icons.sms, '1:1 채팅'),
          if (isAuth)
            _tap(Icons.edit, '프로필 편집', () {
              context.pushNamed('profile-edit', extra: state.user!);
            }),
          if (!isAuth) _tap(Icons.call, '통화하기'),
        ]);
      },
    );
  }

  Widget _tap(IconData icon, String label, [VoidCallback? onPressed]) {
    return TextButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: onPressed,
    );
  }
}
