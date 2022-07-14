import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chatItem = chats[index];
                final chat = chatItem.chat as OpenChat;
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.chat)),
                  title: Text('${chat.title} ${chatItem.info.userCount}'),
                  subtitle: chatItem.info.latestMessage == null
                      ? null
                      : Text(chatItem.info.latestMessage!.message),
                  trailing: chatItem.info.unreadCount == 0
                      ? null
                      : Chip(
                          label: Text('${chatItem.info.unreadCount}'),
                          backgroundColor: Colors.deepOrange,
                        ),
                  onTap: () {
                    Navigator.push(context, ChatPage.route(chat: chat));
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
