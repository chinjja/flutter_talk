import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:talk/pages/chat/bloc/chat_bloc.dart';
import 'package:talk/pages/chat_user_list/bloc/chat_user_list_bloc.dart';
import 'package:talk/repos/repos.dart';

class ChatUserListView extends StatefulWidget {
  const ChatUserListView({Key? key}) : super(key: key);

  @override
  State<ChatUserListView> createState() => _ChatUserListViewState();
}

class _ChatUserListViewState extends State<ChatUserListView> {
  @override
  void initState() {
    super.initState();
    final chat = context.read<ChatBloc>().state.chat;
    if (chat != null) {
      context.read<ChatUserListBloc>().add(ChatUserListStarted(chat: chat));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocConsumer<ChatBloc, ChatState>(
        listenWhen: (previous, current) => previous.chat != current.chat,
        listener: (context, state) {
          if (state.chat != null) {
            context
                .read<ChatUserListBloc>()
                .add(ChatUserListStarted(chat: state.chat!));
          }
        },
        builder: (context, state) {
          if (state.chat == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return const CustomScrollView(
            slivers: [
              _MemberList(),
            ],
          );
        },
      ),
    );
  }
}

class _AddMemberTile extends StatelessWidget {
  const _AddMemberTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () async {
        final bloc = context.read<ChatUserListBloc>();
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider.value(
              value: bloc,
              child: RepositoryProvider.value(
                value: bloc,
                child: const _FriendSelectionView(),
              ),
            ),
            fullscreenDialog: true,
          ),
        );
      },
      leading: const CircleAvatar(child: Icon(Icons.add)),
      title: const Text('대화상대 초대'),
    );
  }
}

class _MemberList extends StatelessWidget {
  const _MemberList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverStickyHeader(
      header: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: const Text('대화상대'),
      ),
      sliver: BlocBuilder<ChatUserListBloc, ChatUserListState>(
        builder: (context, state) {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == 0) {
                  return const _AddMemberTile();
                }
                final item = state.users[index - 1];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(item.user.username),
                );
              },
              childCount: state.users.length + 1,
            ),
          );
        },
      ),
    );
  }
}

class _FriendSelectionView extends StatefulWidget {
  const _FriendSelectionView({
    Key? key,
  }) : super(key: key);

  @override
  State<_FriendSelectionView> createState() => __FriendSelectionViewState();
}

class __FriendSelectionViewState extends State<_FriendSelectionView> {
  final _checked = <String>{};
  List<Friend>? friends;

  @override
  void initState() {
    super.initState();
    context
        .read<ChatRepository>()
        .onFriends
        .first
        .then((data) => setState(() => friends = data));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('친구'),
        actions: [
          IconButton(
            onPressed: _checked.isEmpty
                ? null
                : () {
                    final users = friends!
                        .where((e) => _checked.contains(e.user.username))
                        .map((e) => e.user)
                        .toList();
                    context
                        .read<ChatUserListBloc>()
                        .add(ChatUserListInvited(users));
                    Navigator.pop(context);
                  },
            icon: const Icon(Icons.done),
          ),
        ],
      ),
      body: friends == null
          ? const Center(child: CircularProgressIndicator())
          : BlocBuilder<ChatUserListBloc, ChatUserListState>(
              builder: (context, state) {
                final alreadyChecked =
                    state.users.map((e) => e.user.username).toSet();
                return ListView.builder(
                  itemCount: friends!.length,
                  itemBuilder: (context, index) {
                    final friend = friends![index];
                    final username = friend.user.username;
                    return CheckboxListTile(
                      title: Text(username),
                      value: _checked.contains(username),
                      onChanged: alreadyChecked.contains(username)
                          ? null
                          : (value) {
                              setState(() {
                                if (value ?? false) {
                                  _checked.add(username);
                                } else {
                                  _checked.remove(username);
                                }
                              });
                            },
                    );
                  },
                );
              },
            ),
    );
  }
}
