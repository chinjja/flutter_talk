import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_changed_data.g.dart';

@JsonSerializable()
@CopyWith()
class ChatChangedData extends Equatable {
  final int chatId;
  final String objectType;
  final String command;
  final dynamic data;

  const ChatChangedData({
    required this.chatId,
    required this.objectType,
    required this.command,
    required this.data,
  });

  factory ChatChangedData.fromJson(Map<String, dynamic> json) =>
      _$ChatChangedDataFromJson(json);
  Map<String, dynamic> toJson() => _$ChatChangedDataToJson(this);

  @override
  List<Object?> get props => [chatId, objectType, command, data];
}

@CopyWith()
class ChatChanged<T extends Equatable> extends Equatable {
  final int chatId;
  final String command;
  final T data;

  const ChatChanged(
      {required this.chatId, required this.command, required this.data});

  bool get isAdded => command == "added";
  bool get isUpdated => command == "updated";
  bool get isRemoved => command == "removed";

  @override
  List<Object?> get props => [chatId, command, data];
}
