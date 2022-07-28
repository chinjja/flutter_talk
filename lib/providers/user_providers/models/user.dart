import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
@CopyWith()
class User extends Equatable {
  final String username;
  final String? name;
  final String? state;
  final String? photoId;

  const User({
    required this.username,
    this.name,
    this.state,
    this.photoId,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  List<Object?> get props => [username, name, state, photoId];
}
