import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'token.dart';

part 'user.g.dart';

@JsonSerializable()
@CopyWith()
class User extends Equatable {
  final String username;

  const User({
    required this.username,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  List<Object?> get props => [username];
}

@JsonSerializable(explicitToJson: true)
@CopyWith()
class LoginResponse extends Equatable {
  final bool emailVerified;
  final Token token;

  const LoginResponse({
    required this.emailVerified,
    required this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
  @override
  List<Object?> get props => [emailVerified, token];
}
