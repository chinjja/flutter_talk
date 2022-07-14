import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

import 'models.dart';

part 'open_chat.g.dart';

@JsonSerializable()
@CopyWith()
class OpenChat extends Chat {
  final User owner;
  final String title;
  final String? description;
  final DateTime createdAt;

  const OpenChat({
    required super.id,
    required super.dtype,
    required this.owner,
    required this.title,
    this.description,
    required this.createdAt,
  });

  factory OpenChat.fromJson(Map<String, dynamic> json) =>
      _$OpenChatFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$OpenChatToJson(this);

  @override
  List<Object?> get props => [id, dtype, owner, title, description, createdAt];
}
