import 'package:dio/dio.dart';
import 'package:talk/providers/auth_providers/auth_providers.dart';

class AuthorizationInterceptor extends Interceptor {
  final TokenProvider tokenProvider;
  AuthorizationInterceptor(this.tokenProvider);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await tokenProvider.read();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer ${token.accessToken}';
    }
    super.onRequest(options, handler);
  }
}
