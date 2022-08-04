import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../repos.dart';

class AuthRepository {
  final _authChanged = BehaviorSubject<Authentication?>();
  final AuthProvider _authProvider;
  final TokenProvider _tokenProvider;
  final UserProvider _userProvider;
  final ListenRepository _listenRepository;
  Unsubscribe? _unsubscribe;
  User? _user;

  AuthRepository(
    this._authProvider,
    this._tokenProvider,
    this._userProvider,
    this._listenRepository,
  );

  Stream<Authentication?> get onAuthChanged => _authChanged;
  User? get user => _user;

  late final onUserChanged = _authChanged.map((event) => event?.principal);

  Future init() async {
    _listenRepository.onConnectedUser.listen((user) async {
      if (user == null) {
        _unsubscribe?.call();
        _unsubscribe = null;
      } else {
        _unsubscribe = _listenRepository.subscribeToUser((event) async {
          final old = await _authChanged.first;
          if (old != null) {
            _authChanged.add(old.copyWith.principal(event.user));
          }
        });
      }
    });

    try {
      final token = await _tokenProvider.read();
      if (token != null && !_tokenProvider.isExpired(token.refreshToken)) {
        final map = _tokenProvider.decode(token.accessToken);
        final user = await _userProvider.get(username: map['sub']);
        _user = user;
        _authChanged.add(Authentication(
          principal: user,
          emailVerified: true,
        ));
        return;
      }
    } catch (e) {
      log(e.toString());
    }
    _user = null;
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
    final token =
        await _authProvider.login(username: username, password: password);
    await _tokenProvider.write(token);
    final verified = await _authProvider.isVerified();
    late User user;
    if (verified) {
      user = await _userProvider.get(username: username);
    } else {
      user = User(username: username);
    }
    _user = user;
    _authChanged.add(Authentication(
      principal: user,
      emailVerified: verified,
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
      final user = await _userProvider.get(username: map['sub']);

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

  Future<void> sendResetPassword(String email) async {
    await _authProvider.sendResetPassword(email);
  }
}

extension IsAuthContext on BuildContext {
  bool isAuth(User? user) {
    return user != null &&
        user.username == read<AuthRepository>().user?.username;
  }

  User? get auth => read<AuthRepository>().user;
}
