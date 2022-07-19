import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';

import '../../repos.dart';

part 'authentication.g.dart';

@CopyWith()
class Authentication extends Equatable {
  final User principal;
  final bool emailVerified;

  const Authentication({
    required this.principal,
    required this.emailVerified,
  });

  @override
  List<Object?> get props => [principal, emailVerified];
}
