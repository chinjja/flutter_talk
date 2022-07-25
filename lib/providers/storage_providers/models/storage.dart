import 'dart:typed_data';

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:talk/common/converter/uint8_list_converter.dart';

part 'storage.g.dart';

@JsonSerializable()
@CopyWith()
class StorageData extends Equatable {
  @Uint8ListConverter()
  final Uint8List data;

  const StorageData({
    required this.data,
  });

  factory StorageData.fromJson(Map<String, dynamic> json) =>
      _$StorageDataFromJson(json);

  Map<String, dynamic> toJson() => _$StorageDataToJson(this);

  @override
  List<Object?> get props => [data];
}

@JsonSerializable()
@CopyWith()
class Storage extends Equatable {
  final String id;
  @Uint8ListConverter()
  final Uint8List data;

  const Storage({
    required this.id,
    required this.data,
  });

  factory Storage.fromJson(Map<String, dynamic> json) =>
      _$StorageFromJson(json);

  Map<String, dynamic> toJson() => _$StorageToJson(this);

  @override
  List<Object?> get props => [id, data];
}

@JsonSerializable()
@CopyWith()
class StorageId extends Equatable {
  final String id;

  const StorageId({
    required this.id,
  });

  factory StorageId.fromJson(Map<String, dynamic> json) =>
      _$StorageIdFromJson(json);

  Map<String, dynamic> toJson() => _$StorageIdToJson(this);

  @override
  List<Object?> get props => [id];
}
