import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:talk/repos/repos.dart';

import '../chat_create.dart';

class ChatCreatePage extends StatelessWidget {
  const ChatCreatePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ChatCreateBloc(chatRepository: context.read<ChatRepository>()),
      child: BlocListener<ChatCreateBloc, ChatCreateState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == ChatCreateSubmitStatus.success) {
            context.go('/chat/chats/${state.chatId!}');
          }
        },
        child: const ChatCreateView(),
      ),
    );
  }
}

class ChatCreateView extends StatelessWidget {
  const ChatCreateView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("채팅방 만들기"),
        actions: [
          BlocBuilder<ChatCreateBloc, ChatCreateState>(
            builder: (context, state) {
              return IconButton(
                onPressed: state.isValid
                    ? () {
                        context
                            .read<ChatCreateBloc>()
                            .add(const ChatCreateSubmitted());
                      }
                    : null,
                icon: const Icon(Icons.done),
              );
            },
          ),
        ],
      ),
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            _TitleTextField(),
          ],
        ),
      ),
    );
  }
}

class _TitleTextField extends StatelessWidget {
  const _TitleTextField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCreateBloc, ChatCreateState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: "Title",
              errorText: state.titleError,
            ),
            onChanged: (title) {
              context.read<ChatCreateBloc>().add(ChatCreateTitleChanged(title));
            },
          ),
        );
      },
    );
  }
}
