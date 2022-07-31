import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:talk/repos/repos.dart';

part 'models.g.dart';

typedef Unsubscribe = void Function();
typedef OnChangedEvent = void Function(ChangedEvent event);

typedef OnChatEvent = void Function(ChatEvent event);
typedef OnChatMessageEvent = void Function(ChatMessageEvent event);
typedef OnChatUserEvent = void Function(ChatUserEvent event);
typedef OnFriendEvent = void Function(FriendEvent event);
typedef OnUserEvent = void Function(UserEvent event);

@JsonSerializable()
@CopyWith()
class ChangedEvent extends Equatable {
  final int chatId;
  final String objectType;
  final String command;
  final dynamic data;

  const ChangedEvent({
    required this.chatId,
    required this.objectType,
    required this.command,
    required this.data,
  });

  bool get isAdded => command == "added";
  bool get isUpdated => command == "updated";
  bool get isRemoved => command == "removed";
  factory ChangedEvent.fromJson(Map<String, dynamic> json) =>
      _$ChangedEventFromJson(json);
  Map<String, dynamic> toJson() => _$ChangedEventToJson(this);

  @override
  List<Object?> get props => [chatId, objectType, command, data];
}

class ChatEvent extends Equatable {
  final String command;
  final Chat chat;

  const ChatEvent({required this.command, required this.chat});

  bool get isAdded => command == "added";
  bool get isUpdated => command == "updated";
  bool get isRemoved => command == "removed";

  @override
  List<Object?> get props => [command, chat];
}

class ChatMessageEvent extends Equatable {
  final String command;
  final ChatMessage message;

  const ChatMessageEvent({required this.command, required this.message});

  bool get isAdded => command == "added";
  bool get isUpdated => command == "updated";
  bool get isRemoved => command == "removed";

  @override
  List<Object?> get props => [command, message];
}

class ChatUserEvent extends Equatable {
  final String command;
  final ChatUser chatUser;

  const ChatUserEvent({required this.command, required this.chatUser});

  bool get isAdded => command == "added";
  bool get isUpdated => command == "updated";
  bool get isRemoved => command == "removed";

  @override
  List<Object?> get props => [command, chatUser];
}

class FriendEvent extends Equatable {
  final String command;
  final Friend friend;

  const FriendEvent({required this.command, required this.friend});

  bool get isAdded => command == "added";
  bool get isUpdated => command == "updated";
  bool get isRemoved => command == "removed";

  @override
  List<Object?> get props => [command, friend];
}

class UserEvent extends Equatable {
  final String command;
  final User user;

  const UserEvent({required this.command, required this.user});

  bool get isAdded => command == "added";
  bool get isUpdated => command == "updated";
  bool get isRemoved => command == "removed";

  @override
  List<Object?> get props => [command, user];
}
