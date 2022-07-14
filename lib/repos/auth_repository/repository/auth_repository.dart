import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:rxdart/rxdart.dart';
import 'package:talk/providers/providers.dart';

class AuthRepository {
  final _userChanged = BehaviorSubject<User?>.seeded(null);
  final AuthProvider _authProvider;
  final TokenProvider _tokenProvider;
  User? user;

  AuthRepository(this._authProvider, this._tokenProvider);

  Stream<User?> get onUserChanged => _userChanged;

  Future init() async {
    final token = await _tokenProvider.read();
    if (token != null && !JwtDecoder.isExpired(token.refreshToken)) {
      final map = JwtDecoder.decode(token.accessToken);
      user = User(username: map['sub']);
      _userChanged.add(user);
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
    final token =
        await _authProvider.login(username: username, password: password);
    user = User(username: username);
    await _tokenProvider.write(token);
    _userChanged.add(user);
  }

  Future<void> logout() async {
    await _authProvider.logout();
    user = null;
    await _tokenProvider.clear();
    _userChanged.add(null);
  }
}
