import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:talk/pages/chat/chat.dart';
import 'package:talk/pages/chat_create/chat_create.dart';
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
              Navigator.push(context, ChatCreatePage.route());
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
                final chatItem = chats[index];
                return ListTile(
                  visualDensity: VisualDensity.standard,
                  leading: const CircleAvatar(child: Icon(Icons.chat)),
                  title: _Title(item: chatItem),
                  subtitle:
                      _Message(message: chatItem.info.latestMessage?.message),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _Date(date: chatItem.info.latestMessage?.instant),
                      _Badge(count: chatItem.info.unreadCount),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                        context, ChatPage.route(chat: chatItem.chat));
                  },
                );
              },
            );
          default:
            return const SizedBox();
        }
      },
    );
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
    if (item.chat is OpenChat) {
      final chat = item.chat as OpenChat;
      return Row(
        children: [
          Text(
            chat.title,
            maxLines: 1,
          ),
          const SizedBox(width: 4),
          Flexible(
              child: Text(
            '${item.info.userCount}',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          )),
        ],
      );
    }
    return const Text('제목없는 채팅');
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
    return count == 0
        ? const SizedBox()
        : SizedBox(
            width: 32,
            height: 32,
            child: Chip(
              label:
                  Text('$count', style: const TextStyle(color: Colors.white)),
              backgroundColor: Colors.deepOrange,
            ),
          );
  }
}
