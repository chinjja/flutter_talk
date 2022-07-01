import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:rxdart/rxdart.dart';

import '../models/models.dart';
import 'repository.dart';

class AuthRepository {
  final _userChanged = BehaviorSubject<User?>.seeded(null);
  final Dio _dio;
  final TokenRepository _tokenRepository;
  User? user;

  AuthRepository({
    required Dio dio,
    required TokenRepository tokenRepository,
  })  : _dio = dio,
        _tokenRepository = tokenRepository;

  Stream<User?> get onUserChanged => _userChanged;

  Future init() async {
    final accessToken = await _tokenRepository.accessToken;
    final refreshToken = await _tokenRepository.refreshToken;
    if (accessToken != null &&
        refreshToken != null &&
        !JwtDecoder.isExpired(refreshToken)) {
      final map = JwtDecoder.decode(accessToken);
      user = User(username: map['sub']);
      _userChanged.add(user);
    }
  }

  Future<void> register({
    required String username,
    required String password,
  }) async {
    await _dio.post(
      '/auth/register',
      data: {
        'username': username,
        'password': password,
      },
    );
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    final res = await _dio.post(
      '/auth/login',
      data: {
        'username': username,
        'password': password,
      },
    );
    user = User(username: username);
    await _tokenRepository.setToken(Token.fromJson(res.data));
    _userChanged.add(user);
  }

  Future<void> logout() async {
    await _dio.post('/auth/logout');
    user = null;
    await _tokenRepository.clearToken();
    _userChanged.add(null);
  }
}
