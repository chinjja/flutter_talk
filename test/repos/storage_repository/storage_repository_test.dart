// ignore_for_file: prefer_const_constructors

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talk/repos/repos.dart';

import '../../mocks/mocks.dart';

void main() {
  group('StorageRepository', () {
    late StorageProvider storageProvider;
    late StorageRepository storageRepository;

    setUp(() {
      storageProvider = MockStorageProvider();
      storageRepository = StorageRepository(storageProvider);
    });

    test('get()', () async {
      final data = Uint8List.fromList([1, 2]);
      when(() => storageProvider.get(id: '1'))
          .thenAnswer((_) async => StorageData(data: data));

      final res = await storageRepository.get(id: '1');
      expect(res, data);

      verify(() => storageProvider.get(id: '1')).called(1);
      verifyNoMoreInteractions(storageProvider);
    });

    test('save()', () async {
      final data = Uint8List.fromList([1, 2]);
      final storage = Storage(id: '1', data: data);
      when(() => storageProvider.save(storage))
          .thenAnswer((_) async => StorageId(id: '1'));

      final res = await storageRepository.save(id: '1', data: data);
      expect(res, '1');

      verify(() => storageProvider.save(storage)).called(1);
      verifyNoMoreInteractions(storageProvider);
    });

    test('delete()', () async {
      when(() => storageProvider.delete(id: '1')).thenAnswer((_) async => {});

      await storageRepository.delete(id: '1');

      verify(() => storageProvider.delete(id: '1')).called(1);
      verifyNoMoreInteractions(storageProvider);
    });
  });
}
