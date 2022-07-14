import 'package:equatable/equatable.dart';

import 'models.dart';

abstract class Chat extends Equatable {
  final int id;
  final String dtype;

  const Chat({
    required this.id,
    required this.dtype,
  });

  bool get isOpenChat => dtype == "open";
  bool get isDirectChat => dtype == "direct";
  bool get isGroupChat => dtype == 'group';

  factory Chat.fromJson(Map<String, dynamic> json) {
    final dtype = json['dtype'];
    switch (dtype) {
      case 'open':
        return OpenChat.fromJson(json);
      default:
        throw Exception('oops');
    }
  }

  Map<String, dynamic> toJson();
}
