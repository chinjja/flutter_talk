import 'dart:typed_data';

import 'package:talk/providers/providers.dart';

class StorageRepository {
  final StorageProvider _storageProvider;

  StorageRepository(this._storageProvider);

  Future<Uint8List> get({required String id}) async {
    return await _storageProvider.get(id: id);
  }
}
