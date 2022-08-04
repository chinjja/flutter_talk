import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:talk/common/common.dart';
import 'package:talk/repos/repos.dart';

import '../friend_list.dart';

class FriendListPage extends StatelessWidget {
  const FriendListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FriendListBloc(
        context.auth!,
        context.read<AuthRepository>(),
        context.read<FriendRepository>(),
      )
        ..add(const FriendListListenStarted())
        ..add(const FriendListUserListenStarted()),
      child: const FriendListView(),
    );
  }
}

class FriendListView extends StatelessWidget {
  const FriendListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<FriendListBloc>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('친구'),
        actions: [
          IconButton(
            onPressed: () {
              showDialog<User?>(
                context: context,
                builder: (context) {
                  return BlocProvider.value(
                    value: bloc,
                    child: const _UserSearchAlertDialog(),
                  );
                },
              );
            },
            icon: const Icon(Icons.person_add),
          )
        ],
      ),
      body: const CustomScrollView(
        slivers: [
          _SliverUserView(),
          _SliverDivider(),
          _SliverFriendHeaderView(),
          _SliverFriendListView(),
        ],
      ),
    );
  }
}

class _UserSearchAlertDialog extends StatefulWidget {
  const _UserSearchAlertDialog({Key? key}) : super(key: key);

  @override
  State<_UserSearchAlertDialog> createState() => __UserSearchAlertDialogState();
}

class __UserSearchAlertDialogState extends State<_UserSearchAlertDialog> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return BlocListener<FriendListBloc, FriendListState>(
      listenWhen: (previous, current) =>
          previous.addStatus != current.addStatus,
      listener: (context, state) {
        if (state.addStatus == FriendListStatus.success) {
          Navigator.pop(context);
        }
        if (state.addStatus == FriendListStatus.failure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text('Can not search [${_controller.text}]'),
              ),
            );
          _focus.requestFocus();
        }
      },
      child: BlocBuilder<FriendListBloc, FriendListState>(
        builder: (context, state) {
          return AlertDialog(
            title: const Text('친구 아이디 입력'),
            content: TextField(
              autofocus: true,
              controller: _controller,
              focusNode: _focus,
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  context
                      .read<FriendListBloc>()
                      .add(FriendAdded(_controller.text));
                },
                child: state.addStatus == FriendListStatus.loading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : const Text('친구 추가'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('취소'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SliverUserView extends StatelessWidget {
  const _SliverUserView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FriendListBloc, FriendListState>(
      builder: (context, state) {
        return SliverToBoxAdapter(
          child: _FriendTile(user: state.user),
        );
      },
    );
  }
}

class _SliverDivider extends StatelessWidget {
  const _SliverDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter(child: Divider());
  }
}

class _SliverFriendHeaderView extends StatelessWidget {
  const _SliverFriendHeaderView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            const Text('친구'),
            const SizedBox(width: 8),
            BlocBuilder<FriendListBloc, FriendListState>(
                builder: (context, state) {
              return Text('${state.friends.length}');
            }),
          ],
        ),
      ),
    );
  }
}

class _SliverFriendListView extends StatelessWidget {
  const _SliverFriendListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FriendListBloc, FriendListState>(
      builder: (context, state) {
        if (state.status == FriendListStatus.loading) {
          return const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()));
        }
        if (state.friends.isEmpty) {
          return const SliverToBoxAdapter(
              child: Center(child: Text('친구가 없습니다.')));
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final friend = state.friends[index];
              return _FriendTile(user: friend.user);
            },
            childCount: state.friends.length,
          ),
        );
      },
    );
  }
}

class _FriendTile extends StatelessWidget {
  final User? user;
  const _FriendTile({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return UserTile(
      user,
      onTap: user != null
          ? () {
              context.goNamed('profile', params: {
                'tab': 'home',
                'username': user!.username,
              });
            }
          : null,
    );
  }
}
