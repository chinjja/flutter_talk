import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:talk/app/app.dart';
import 'package:talk/repos/repos.dart';

import '../profile.dart';

class ProfilePage extends StatelessWidget {
  final String username;

  const ProfilePage({Key? key, required this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(context.read<UserRepository>())
        ..add(ProfileStarted(username)),
      child: const ProfileView(),
    );
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = context.select((AppBloc bloc) => bloc.state.user);
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        bool hasPhoto = state.user?.photoId != null;
        return Container(
          color: hasPhoto ? null : Theme.of(context).colorScheme.surface,
          decoration: hasPhoto
              ? BoxDecoration(
                  image: DecorationImage(
                    image: MemoryImage(Uint8List.fromList([])),
                    fit: BoxFit.cover,
                  ),
                )
              : null,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
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
                children: [
                  const CircleAvatar(
                    radius: 32,
                    child: Icon(
                      Icons.person,
                      size: 48,
                    ),
                  ),
                  Text(state.user?.username ?? '???'),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    _tap(Icons.sms, '1:1 채팅'),
                    if (state.user == auth)
                      _tap(Icons.edit, '프로필 편집', () {
                        context.pushNamed('profile-edit', extra: state.user!);
                      }),
                    if (state.user != auth) _tap(Icons.call, '통화하기'),
                  ])
                ],
              ),
            ),
          ),
        );
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
