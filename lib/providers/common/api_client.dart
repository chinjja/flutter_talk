import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../providers.dart';

class ApiClient extends http.BaseClient {
  final String baseUrl;

  final http.Client _client;
  final TokenProvider _tokenProvider;
  ApiClient(this.baseUrl, this._client, this._tokenProvider);

  Uri uri(String path, [Map<String, dynamic>? queryParameters]) {
    return Uri.https(baseUrl, path, queryParameters);
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final token = await _tokenProvider.read();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer ${token.accessToken}';
    }
    final res = await _client.send(request);
    if (token != null && res.statusCode == 401) {
      final refreshResponse = await http.post(
        Uri.https(baseUrl, '/auth/refresh'),
        body: token.toJson(),
      );
      switch (refreshResponse.statusCode) {
        case 200:
          final json = jsonDecode(refreshResponse.body);
          await _tokenProvider
              .write(token.copyWith.accessToken(json['accessToken']));
          request.headers['Authorization'] = 'Bearer ${token.accessToken}';
          return _client.send(request);
        case 401:
          await _tokenProvider.clear();
          // logout
          break;
      }
    }
    if (res.statusCode - 400 >= 0) {
      throw AuthClientException(res);
    }
    return res;
  }
}

class AuthClientException implements IOException {
  final http.StreamedResponse response;

  const AuthClientException(this.response);
}

//  Future<bool> _refresh() async {
//     final token = await tokenProvider.read();
//     if (token != null) {
//       final refreshDio = Dio(BaseOptions(baseUrl: dio.options.baseUrl));
//       try {
//         final res = await refreshDio.post(
//           '/auth/refresh',
//           data: token.toJson(),
//         );
//         await tokenProvider
//             .write(token.copyWith(accessToken: res.data['accessToken']));
//         return true;
//       } on DioError catch (e) {
//         if (e.response?.statusCode == HttpStatus.unauthorized) {
//           authRepository.logout();
//         }
//       }
//     }
//     return false;
//   }

//  dio.interceptors.add(InterceptorsWrapper(
//     onRequest: (options, handler) async {
//       final token = await tokenProvider.read();
//       if (token != null) {
//         options.headers['Authorization'] = 'Bearer ${token.accessToken}';
//       }
//       handler.next(options);
//     },
//     onError: (error, handler) async {
//       if (error.response?.statusCode == HttpStatus.unauthorized) {
//         if (await _refresh()) {
//           final response = await dio.request(
//             error.requestOptions.path,
//             options: Options(
//               method: error.requestOptions.method,
//               headers: error.requestOptions.headers,
//             ),
//             data: error.requestOptions.data,
//             queryParameters: error.requestOptions.queryParameters,
//           );
//           return handler.resolve(response);
//         }
//       }
//       return handler.next(error);
//     },
//   ));