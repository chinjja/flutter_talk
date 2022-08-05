import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:go_router/go_router.dart';
import 'package:talk/common/common.dart';
import 'package:talk/repos/repos.dart';

import '../profile.dart';

class ProfilePage extends StatelessWidget {
  final String username;
  final User? user;

  const ProfilePage({
    Key? key,
    required this.username,
    this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(
        user: user,
        userRepository: context.read<UserRepository>(),
        chatRepository: context.read<ChatRepository>(),
        listenRepository: context.read<ListenRepository>(),
      )..add(ProfileStarted(username)),
      child: MultiBlocListener(
        listeners: [
          BlocListener<ProfileBloc, ProfileState>(
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: (context, state) {
              if (state.status == FetchStatus.failure) {
                showError(context, state.error);
              }
            },
          ),
          BlocListener<ProfileBloc, ProfileState>(
            listenWhen: (previous, current) =>
                previous.directChatStatus != current.directChatStatus,
            listener: (context, state) {
              if (state.directChatStatus.isSubmissionSuccess) {
                context.goNamed(
                  'chats',
                  params: {
                    'tab': 'chat',
                    'chatId': '${state.directChat!.id}',
                  },
                  extra: state.directChat,
                );
              }
            },
          ),
        ],
        child: const ProfileView(),
      ),
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
            child: Padding(
              padding: const EdgeInsets.all(16),
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
        final user = state.user;
        final isAuth = context.isAuth(user);
        return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (!isAuth)
            _tap(user, Icons.sms, '1:1 채팅', () {
              context.read<ProfileBloc>().add(const ProfileDirectChatClicked());
            }),
          if (isAuth)
            _tap(user, Icons.edit, '프로필 편집', () {
              context.pushNamed('profile-edit', extra: state.user!);
            }),
          if (!isAuth) _tap(user, Icons.call, '통화하기'),
        ]);
      },
    );
  }

  Widget _tap(User? user, IconData icon, String label,
      [VoidCallback? onPressed]) {
    return TextButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: user == null ? null : onPressed,
    );
  }
}
