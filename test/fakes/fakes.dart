import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeResponse extends Fake implements Response {
  final dynamic _data;
  FakeResponse({dynamic data}) : _data = data;

  @override
  dynamic get data => _data;
}
