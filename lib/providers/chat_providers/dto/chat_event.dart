import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';

part 'chat_event.g.dart';

@CopyWith()
class ChatEvent<T extends Equatable> extends Equatable {
  final String command;
  final T data;

  const ChatEvent({required this.command, required this.data});

  bool get isAdded => command == "added";
  bool get isUpdated => command == "updated";
  bool get isRemoved => command == "removed";

  @override
  List<Object?> get props => [command, data];
}
