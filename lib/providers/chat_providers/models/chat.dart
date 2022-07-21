import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'models.dart';

part 'chat.g.dart';

@JsonSerializable(explicitToJson: true)
@CopyWith()
class Chat extends Equatable {
  final int id;

  final bool visible;
  final bool joinable;

  final String? title;
  final String? description;

  final User? owner;

  final DateTime createdAt;

  const Chat({
    required this.id,
    required this.createdAt,
    this.visible = false,
    this.joinable = false,
    this.title,
    this.description,
    this.owner,
  });

  factory Chat.fromJson(Map<String, dynamic> json) => _$ChatFromJson(json);

  Map<String, dynamic> toJson() => _$ChatToJson(this);

  @override
  List<Object?> get props => [
        id,
        createdAt,
        visible,
        joinable,
        title,
        description,
        owner,
      ];
}
