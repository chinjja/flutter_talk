import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../chat_providers.dart';

part 'chat_info.g.dart';

@JsonSerializable()
@CopyWith()
class ChatInfo extends Equatable {
  final int unreadCount;
  final int userCount;
  final ChatMessage? latestMessage;

  const ChatInfo({
    required this.unreadCount,
    required this.userCount,
    required this.latestMessage,
  });

  factory ChatInfo.fromJson(Map<String, dynamic> json) =>
      _$ChatInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ChatInfoToJson(this);
  @override
  List<Object?> get props => [unreadCount, userCount, latestMessage];
}
