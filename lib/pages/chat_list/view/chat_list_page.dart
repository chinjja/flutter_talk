import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:talk/common/common.dart';
import 'package:talk/repos/repos.dart';

import '../chat_list.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatListBloc(
        chatRepository: context.read<ChatRepository>(),
      )..add(const ChatListStarted()),
      child: const ChatListView(),
    );
  }
}

class ChatListView extends StatelessWidget {
  const ChatListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('채팅'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.push('/new-chat');
            },
          )
        ],
      ),
      body: const _ChatListView(),
    );
  }
}

class _ChatListView extends StatelessWidget {
  const _ChatListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatListBloc, ChatListState>(
      builder: (context, state) {
        switch (state.status) {
          case ChatListStatus.loading:
            return const Center(child: CircularProgressIndicator());
          case ChatListStatus.success:
            final chats = state.chats;
            if (chats.isEmpty) {
              return const Center(child: Text('채팅방이 없습니다.'));
            }
            return ListView.builder(
              itemExtent: 80,
              itemCount: chats.length,
              itemBuilder: (context, index) {
                return _ChatTile(chatItem: chats[index]);
              },
            );
          default:
            return const SizedBox();
        }
      },
    );
  }
}

class _ChatTile extends StatelessWidget {
  final ChatItem chatItem;
  const _ChatTile({Key? key, required this.chatItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        extentRatio: 0.2,
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (context) async {
              if (chatItem.chat.owner == context.auth) {
                await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: const Text('방 소유자는 떠날 수 없습니다.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('닫기'),
                          ),
                        ],
                      );
                    });
                return;
              }
              context.read<ChatListBloc>().add(ChatListLeaved(chatItem.chat));
            },
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
            icon: Icons.exit_to_app,
            label: '나가기',
          ),
        ],
      ),
      child: ListTile(
        visualDensity: VisualDensity.standard,
        leading: _Icon(item: chatItem),
        title: _Title(item: chatItem),
        subtitle: _Message(message: chatItem.info.latestMessage?.message),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _Date(date: chatItem.info.latestMessage?.instant),
            _Badge(count: chatItem.info.unreadCount),
          ],
        ),
        onTap: () {
          context.go('/chat/chats/${chatItem.chat.id}');
        },
      ),
    );
  }
}

class _Icon extends StatelessWidget {
  final ChatItem item;
  const _Icon({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = context.auth;
    switch (item.chat.type) {
      case 'direct':
        return item.info.users
            .where((e) => e.username != auth?.username)
            .map((e) => UserAvatar(e))
            .first;
      case 'open':
      case 'group':
        List<User?> users = [
          ...item.info.users.where((e) => e.username != auth?.username).take(4)
        ];
        while (users.length < 4) {
          users.add(null);
        }
        return SizedBox(
          width: 40,
          child: Wrap(
            children: users
                .map((e) => Padding(
                      padding: const EdgeInsets.all(1),
                      child:
                          SizedBox(width: 18, height: 18, child: UserAvatar(e)),
                    ))
                .toList(),
          ),
        );
    }
    return const SizedBox();
  }
}

class _Message extends StatelessWidget {
  final String? message;
  const _Message({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return message == null ? const SizedBox() : Text(message!, maxLines: 2);
  }
}

class _Title extends StatelessWidget {
  final ChatItem item;
  const _Title({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = context.auth;
    String title = '제목없는 채팅';
    switch (item.chat.type) {
      case 'direct':
        title = item.info.users
            .where((e) => e.username != auth?.username)
            .map((e) => e.name ?? e.username)
            .first;
        break;
      case 'open':
      case 'group':
        title = item.chat.title ??
            item.info.users
                .where((e) => e.username != auth?.username)
                .take(4)
                .fold('', (a, user) => a + (user.name ?? user.username));
        break;
    }

    return Row(
      children: [
        Text(
          title,
          maxLines: 1,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            '${item.info.userCount}',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ],
    );
  }
}

class _Date extends StatelessWidget {
  final DateTime? date;

  const _Date({Key? key, required this.date}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return date == null
        ? const SizedBox()
        : Text(
            DateFormat.yMd().format(date!),
          );
  }
}

class _Badge extends StatelessWidget {
  final int count;
  const _Badge({Key? key, required this.count}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: count > 0,
      child: Chip(
        label: Text(
          '$count',
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepOrange,
      ),
    );
  }
}
