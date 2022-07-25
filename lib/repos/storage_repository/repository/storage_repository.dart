import 'dart:typed_data';

import 'package:talk/providers/providers.dart';

class StorageRepository {
  final StorageProvider _storageProvider;

  StorageRepository(this._storageProvider);

  Future<Uint8List> get({required String id}) async {
    var res = await _storageProvider.get(id: id);
    return res.data;
  }

  Future<String> save({required String id, required Uint8List data}) async {
    final res = await _storageProvider.save(Storage(id: id, data: data));
    return res.id;
  }

  Future<void> delete({required String id}) async {
    await _storageProvider.delete(id: id);
  }
}
