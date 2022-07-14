import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:talk/providers/chat_providers/dto/chat_info.dart';

import '../../repos.dart';

part 'chat_item.g.dart';

@CopyWith()
class ChatItem extends Equatable {
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
}
