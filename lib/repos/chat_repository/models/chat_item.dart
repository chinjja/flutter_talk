import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';

import '../../repos.dart';

part 'chat_item.g.dart';

@CopyWith()
class ChatItem extends Equatable implements Comparable<ChatItem> {
  final Chat chat;
  final ChatInfo info;

  const ChatItem({
    required this.chat,
    required this.info,
  });

  @override
  List<Object?> get props => [
        chat,
        info,
      ];

  @override
  int compareTo(ChatItem other) {
    final a = info.latestMessage?.instant ?? chat.createdAt;
    final b = other.info.latestMessage?.instant ?? other.chat.createdAt;
    return b.compareTo(a);
  }
}
