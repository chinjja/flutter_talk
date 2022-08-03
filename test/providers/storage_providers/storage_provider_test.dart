// ignore_for_file: prefer_const_constructors

import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talk/repos/repos.dart';

import '../../fakes/fakes.dart';
import '../../mocks/mocks.dart';

void main() {
  group('StorageProvider', () {
    late Dio dio;
    late StorageProvider storageProvider;

    setUp(() {
      dio = MockDio();
      storageProvider = StorageProvider(dio);
    });

    test('get()', () async {
      final data = Uint8List.fromList([1, 2]);
      when(() => dio.get(
            '/storage/1',
            options: any(named: 'options'),
          )).thenAnswer((_) async => FakeResponse(data: data));

      final res = await storageProvider.get(id: '1');
      expect(res, data);
    });
  });
}
