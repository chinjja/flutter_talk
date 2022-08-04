import 'dart:io';

import 'package:dio/dio.dart';
import 'package:talk/providers/auth_providers/auth_providers.dart';
import 'package:talk/repos/auth_repository/auth_repository.dart';

class RefreshInterceptor extends Interceptor {
  final Dio dio;
  final TokenProvider tokenProvider;
  final AuthRepository authRepository;
  RefreshInterceptor(this.dio, this.tokenProvider, this.authRepository);

  Future<bool> _refresh(RequestOptions options) async {
    final token = await tokenProvider.read();
    if (token != null) {
      final refreshDio = Dio(BaseOptions(baseUrl: dio.options.baseUrl));
      try {
        final res = await refreshDio.post(
          '/auth/refresh',
          data: token.toJson(),
        );
        await tokenProvider
            .write(token.copyWith(accessToken: res.data['accessToken']));
        return true;
      } on DioError catch (e) {
        if (e.response?.statusCode == HttpStatus.unauthorized) {
          authRepository.logout();
        }
      } finally {
        refreshDio.close();
      }
    }
    return false;
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == HttpStatus.unauthorized) {
      if (await _refresh(err.requestOptions)) {
        final response = await dio.request(
          err.requestOptions.path,
          options: Options(
            method: err.requestOptions.method,
            headers: err.requestOptions.headers,
          ),
          data: err.requestOptions.data,
          queryParameters: err.requestOptions.queryParameters,
        );

        handler.resolve(response);
        return;
      }
    }
    super.onError(err, handler);
  }
}
