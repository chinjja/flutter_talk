import 'package:formz/formz.dart';

class Username extends FormzInput<String, bool> {
  const Username.pure() : super.pure('');
  const Username.dirty(super.value) : super.dirty();

  @override
  bool? validator(String value) {
    final idx = value.indexOf('@');
    if (idx == -1) return false;

    final idx2 = value.indexOf('.', idx);
    if (idx2 == -1) return false;

    if (value.length <= idx2 + 1) return false;
    return null;
  }
}

class Password extends FormzInput<String, bool> {
  const Password.pure() : super.pure('');
  const Password.dirty(super.value) : super.dirty();

  @override
  bool? validator(String value) {
    if (value.length < 4) return false;
    return null;
  }
}

class ConfirmPassword extends FormzInput<String, bool> {
  final String origin;

  const ConfirmPassword.pure()
      : origin = '',
        super.pure('');
  const ConfirmPassword.dirty(this.origin, super.value) : super.dirty();

  @override
  bool? validator(String value) {
    if (origin != value) return false;
    return null;
  }
}
