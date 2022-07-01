import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'models.dart';

part 'chat_user.g.dart';

@JsonSerializable()
@CopyWith()
class ChatUser extends Equatable {
  final int id;
  final Chat chat;
  final User user;
  final DateTime readAt;

  const ChatUser({
    required this.id,
    required this.chat,
    required this.user,
    required this.readAt,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) =>
      _$ChatUserFromJson(json);
  Map<String, dynamic> toJson() => _$ChatUserToJson(this);

  @override
  List<Object?> get props => [id, chat, user];
}
