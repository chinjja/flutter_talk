import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:talk/pages/chat_user_list/bloc/chat_user_list_bloc.dart';
import 'package:talk/pages/chat_user_list/view/chat_user_list_view.dart';
import 'package:talk/repos/repos.dart';

import '../chat.dart';

class ChatPage extends StatelessWidget {
  final int chatId;
  const ChatPage({Key? key, required this.chatId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthRepository>().user;
    final chatRepo = context.read<ChatRepository>();
    final listenRepo = context.read<ListenRepository>();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) => ChatBloc(
                  chatRepository: chatRepo,
                  listenRepository: listenRepo,
                )..add(ChatStarted(chatId: chatId, user: user!))),
        BlocProvider(
            create: (context) => ChatUserListBloc(
                  chatRepository: chatRepo,
                  listenRepository: listenRepo,
                )),
      ],
      child: BlocListener<ChatBloc, ChatState>(
        listenWhen: (previous, current) => previous.removed != current.removed,
        listener: (context, state) {
          if (state.removed) {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: const Text('이 방은 삭제되었습니다.'),
                  actions: [
                    TextButton(
                      child: const Text('나가기'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
              },
            );
          }
        },
        child: const ChatView(),
      ),
    );
  }
}

class ChatView extends StatelessWidget {
  const ChatView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.primary,
      appBar: AppBar(
        title: const _AppBarTitle(),
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: ColoredBox(
          color: colorScheme.surface,
          child: Column(
            children: const [
              _MessageView(),
              _BottomView(),
            ],
          ),
        ),
      ),
      endDrawer: const Drawer(child: ChatUserListView()),
    );
  }
}

class _AppBarTitle extends StatelessWidget {
  const _AppBarTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        final chat = state.chat;
        if (chat == null) {
          return const SizedBox();
        }
        return Text(chat.title ?? '제목 없음');
      },
    );
  }
}

class _MessageView extends StatefulWidget {
  const _MessageView({Key? key}) : super(key: key);

  @override
  State<_MessageView> createState() => __MessageViewState();
}

class __MessageViewState extends State<_MessageView> {
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_scrollChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_scrollChanged);
    _controller.dispose();
    super.dispose();
  }

  void _scrollChanged() {
    if (!_controller.hasClients) return;
    if (!context.read<ChatBloc>().state.hasNextMessage) return;

    if (_controller.offset > _controller.position.maxScrollExtent - 200) {
      context.read<ChatBloc>().add(const ChatMessageFetchMore());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state.fetchStatus == ChatStatus.inProgress) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            controller: _controller,
            reverse: true,
            padding: const EdgeInsets.all(4),
            itemCount: state.messages.length + (state.hasNextMessage ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == state.messages.length) {
                return const Center(child: CircularProgressIndicator());
              }
              final prevMessage = index < state.messages.length - 1
                  ? state.messages[index + 1]
                  : null;
              final message = state.messages[index];
              final myMessage = message.sender.username == state.user?.username;
              var unreadCount = 0;
              var unreadOverflow = false;
              for (final chatUser in state.chatUsers) {
                if (chatUser.user == state.user) continue;

                if (message.instant.compareTo(chatUser.readAt) > 0) {
                  unreadCount++;
                  if (unreadCount == 100) {
                    unreadCount--;
                    unreadOverflow = true;
                    break;
                  }
                }
              }
              if (myMessage) {
                return _MyMessageTile(
                  prevMessage: prevMessage,
                  message: message,
                );
              }
              return _MessageTile(
                prevMessage: prevMessage,
                message: message,
                unreadCount: unreadCount,
                unreadOverflow: unreadOverflow,
              );
            },
          );
        },
      ),
    );
  }
}

class _BottomView extends StatefulWidget {
  const _BottomView({Key? key}) : super(key: key);

  @override
  State<_BottomView> createState() => __BottomViewState();
}

class __BottomViewState extends State<_BottomView> {
  final controller = TextEditingController();
  final focusNode = FocusNode();

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BlocConsumer<ChatBloc, ChatState>(
      listenWhen: (previous, current) =>
          previous.submitStatus != current.submitStatus,
      listener: (context, state) {
        if (state.submitStatus == ChatStatus.success) {
          controller.text = state.message;
          focusNode.requestFocus();
        }
      },
      builder: (context, state) {
        return Container(
          color: colorScheme.primary,
          padding: const EdgeInsets.all(3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 40,
                child: IconButton(
                  icon: Icon(Icons.add, color: colorScheme.onPrimary),
                  onPressed: () {},
                ),
              ),
              Expanded(
                child: TextField(
                  focusNode: focusNode,
                  controller: controller,
                  minLines: 1,
                  maxLines: 5,
                  onChanged: (message) {
                    context.read<ChatBloc>().add(ChatMessageChanged(message));
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    fillColor: colorScheme.background,
                    filled: true,
                    suffixIcon: TextButton(
                      onPressed: state.isValid
                          ? () {
                              context
                                  .read<ChatBloc>()
                                  .add(const ChatMessageSubmitted());
                            }
                          : null,
                      style: TextButton.styleFrom(
                        primary: colorScheme.onPrimary,
                      ),
                      child: const Text('Send'),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 6,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MyMessageTile extends StatelessWidget {
  final ChatMessage? prevMessage;
  final ChatMessage message;
  const _MyMessageTile({
    Key? key,
    required this.prevMessage,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firstMessage = message.sender != prevMessage?.sender;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (firstMessage) const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(width: 48),
            _TimeText(
              time: message.instant,
              alignment: Alignment.bottomRight,
            ),
            _MessageText(text: message.message),
          ],
        ),
      ],
    );
  }
}

class _MessageTile extends StatelessWidget {
  final ChatMessage? prevMessage;
  final ChatMessage message;
  final int unreadCount;
  final bool unreadOverflow;
  const _MessageTile({
    Key? key,
    required this.prevMessage,
    required this.message,
    required this.unreadCount,
    required this.unreadOverflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firstMessage = message.sender != prevMessage?.sender;
    return Padding(
      padding: firstMessage ? const EdgeInsets.only(top: 10) : EdgeInsets.zero,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 48,
            child: firstMessage
                ? const CircleAvatar(
                    child: Icon(Icons.person),
                  )
                : null,
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (firstMessage) Text(message.sender.username),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _MessageText(text: message.message),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _UnreadCount(
                            unreadCount: unreadCount, overflow: unreadOverflow),
                        _TimeText(
                          time: message.instant,
                          alignment: Alignment.bottomLeft,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UnreadCount extends StatelessWidget {
  final int unreadCount;
  final bool overflow;
  const _UnreadCount({
    Key? key,
    required this.unreadCount,
    required this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: unreadCount > 0,
      child: Text(
        '$unreadCount${overflow ? '+' : ''}',
        style: const TextStyle(
          color: Colors.orange,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _TimeText extends StatelessWidget {
  final DateTime time;
  final Alignment alignment;
  const _TimeText({
    Key? key,
    required this.time,
    required this.alignment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      alignment: alignment,
      padding: const EdgeInsets.all(2),
      child: Text(
        DateFormat.jm().format(time),
        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
      ),
    );
  }
}

class _MessageText extends StatelessWidget {
  final String text;
  const _MessageText({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Flexible(
      child: Container(
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: ShapeDecoration(
          color: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(color: colorScheme.onPrimary),
        ),
      ),
    );
  }
}
