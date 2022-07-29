import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'user.dart';

part 'friend.g.dart';

@JsonSerializable(explicitToJson: true)
@CopyWith()
class Friend extends Equatable {
  final User user;
  final String? name;

  const Friend({
    required this.user,
    this.name,
  });

  factory Friend.fromJson(Map<String, dynamic> json) => _$FriendFromJson(json);
  Map<String, dynamic> toJson() => _$FriendToJson(this);

  @override
  List<Object?> get props => [user, name];
}
