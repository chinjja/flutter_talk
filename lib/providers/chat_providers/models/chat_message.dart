import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'models.dart';

part 'chat_message.g.dart';

@JsonSerializable(explicitToJson: true)
@CopyWith()
class ChatMessage extends Equatable {
  final int id;
  final User sender;
  final String message;
  final DateTime instant;

  const ChatMessage({
    required this.id,
    required this.sender,
    required this.message,
    required this.instant,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);

  @override
  List<Object?> get props => [id, sender, message, instant];
}
