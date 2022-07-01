import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_changed_data.g.dart';

@JsonSerializable()
@CopyWith()
class ChatChangedData extends Equatable {
  final String type;
  final int chatId;
  final dynamic data;

  const ChatChangedData({
    required this.type,
    required this.chatId,
    required this.data,
  });

  factory ChatChangedData.fromJson(Map<String, dynamic> json) =>
      _$ChatChangedDataFromJson(json);
  Map<String, dynamic> toJson() => _$ChatChangedDataToJson(this);

  @override
  List<Object?> get props => [type, chatId, data];
}
