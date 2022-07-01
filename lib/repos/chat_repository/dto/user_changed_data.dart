import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_changed_data.g.dart';

@JsonSerializable()
@CopyWith()
class UserChangedData extends Equatable {
  final String type;
  final dynamic data;

  const UserChangedData({
    required this.type,
    required this.data,
  });

  factory UserChangedData.fromJson(Map<String, dynamic> json) =>
      _$UserChangedDataFromJson(json);
  Map<String, dynamic> toJson() => _$UserChangedDataToJson(this);

  @override
  List<Object?> get props => [type, data];
}
