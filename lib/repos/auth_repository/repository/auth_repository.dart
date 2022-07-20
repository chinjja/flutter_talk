import 'dart:developer';

import 'package:rxdart/rxdart.dart';
import 'package:talk/providers/providers.dart';

import '../auth_repository.dart';

class AuthRepository {
  final _authChanged = BehaviorSubject<Authentication?>();
  final AuthProvider _authProvider;
  final TokenProvider _tokenProvider;
  User? _user;

  AuthRepository(this._authProvider, this._tokenProvider);

  Stream<Authentication?> get onAuthChanged => _authChanged;
  User? get user => _user;

  Future init() async {
    try {
      final data = await _tokenProvider.read();
      if (data != null && !_tokenProvider.isExpired(data.refreshToken)) {
        final verified = await isVerified();
        final map = _tokenProvider.decode(data.accessToken);
        var user = User(username: map['sub']);
        _user = user;
        _authChanged.add(Authentication(
          principal: user,
          emailVerified: verified,
        ));
        return;
      }
    } catch (e) {
      log(e.toString());
    }
    _tokenProvider.clear();
    _authChanged.add(null);
  }

  Future<void> register({
    required String username,
    required String password,
  }) async {
    await _authProvider.register(username: username, password: password);
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    final res =
        await _authProvider.login(username: username, password: password);
    var user = User(username: username);
    _user = user;
    await _tokenProvider.write(res.token);

    _authChanged.add(Authentication(
      principal: user,
      emailVerified: res.emailVerified,
    ));
  }

  Future<void> logout() async {
    try {
      await _authProvider.logout();
    } catch (_) {}
    _user = null;
    try {
      await _tokenProvider.clear();
    } catch (_) {}
    _authChanged.add(null);
  }

  Future<void> sendCode() async {
    await _authProvider.sendCode();
  }

  Future<void> verifyCode(String code) async {
    await _authProvider.verifyCode(code);

    final data = await _tokenProvider.read();
    if (data != null) {
      final map = _tokenProvider.decode(data.accessToken);
      var user = User(username: map['sub']);

      _user = user;
      _authChanged.add(Authentication(
        principal: user,
        emailVerified: true,
      ));
    }
  }

  Future<bool> isVerified() async {
    return await _authProvider.isVerified();
  }
}
