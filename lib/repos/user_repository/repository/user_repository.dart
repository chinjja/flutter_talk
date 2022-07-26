import 'dart:typed_data';

import 'package:talk/providers/providers.dart';

class UserRepository {
  final UserProvider _userProvider;

  UserRepository(this._userProvider);

  Future<User> get({required String username}) async {
    return _userProvider.get(username: username);
  }

  Future<User> update({String? name, String? state, Uint8List? photo}) async {
    return _userProvider.update(name: name, state: state, photo: photo);
  }
}
