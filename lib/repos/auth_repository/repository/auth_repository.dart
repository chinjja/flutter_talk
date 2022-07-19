import 'dart:developer';

import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:rxdart/rxdart.dart';
import 'package:talk/providers/providers.dart';

import '../auth_repository.dart';

class AuthRepository {
  final _userChanged = BehaviorSubject<Authentication?>.seeded(null);
  final AuthProvider _authProvider;
  final TokenProvider _tokenProvider;
  User? user;

  AuthRepository(this._authProvider, this._tokenProvider);

  Stream<Authentication?> get onUserChanged => _userChanged;

  Future init() async {
    final data = await _tokenProvider.read();
    if (data != null && !JwtDecoder.isExpired(data.refreshToken)) {
      try {
        final verified = await isVerified();
        final map = JwtDecoder.decode(data.accessToken);
        var user = User(username: map['sub']);
        this.user = user;
        _userChanged.add(Authentication(
          principal: user,
          emailVerified: verified,
        ));
      } catch (e) {
        _tokenProvider.clear();
        log(e.toString());
      }
    }
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
    this.user = user;
    await _tokenProvider.write(res.token);

    _userChanged.add(Authentication(
      principal: user,
      emailVerified: res.emailVerified,
    ));
  }

  Future<void> logout() async {
    await _authProvider.logout();
    user = null;
    await _tokenProvider.clear();
    _userChanged.add(null);
  }

  Future<void> sendCode() async {
    await _authProvider.sendCode();
  }

  Future<void> verifyCode(int code) async {
    await _authProvider.verifyCode(code);

    final auth = await _userChanged.first.timeout(const Duration(seconds: 1));
    if (auth != null) {
      _userChanged.add(auth.copyWith.emailVerified(true));
    }
  }

  Future<bool> isVerified() async {
    return await _authProvider.isVerified();
  }
}
