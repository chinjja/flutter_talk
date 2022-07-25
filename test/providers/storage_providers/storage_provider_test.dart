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

    test('save()', () async {
      final data = Uint8List.fromList([1, 2]);
      final storage = Storage(id: '1', data: data);
      final res = StorageId(id: '1');
      when(() => dio.post('/storage', data: storage.toJson()))
          .thenAnswer((_) async => FakeResponse(data: res.toJson()));

      final saved = await storageProvider.save(storage);
      expect(saved, res);
    });

    test('get()', () async {
      final data = Uint8List.fromList([1, 2]);
      final res = StorageData(data: data);
      when(() => dio.get('/storage/1'))
          .thenAnswer((_) async => FakeResponse(data: res.toJson()));

      final loaded = await storageProvider.get(id: '1');
      expect(loaded, res);
    });

    test('delete()', () async {
      when(() => dio.delete('/storage/1'))
          .thenAnswer((_) async => FakeResponse());

      await storageProvider.delete(id: '1');

      verify(() => dio.delete('/storage/1')).called(1);
    });
  });
}
