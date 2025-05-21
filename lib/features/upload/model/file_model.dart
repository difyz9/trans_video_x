import 'package:json_annotation/json_annotation.dart';

part 'file_model.g.dart';

@JsonSerializable()
class FileModel {
  @JsonKey(name: 'file_array')
  final List<String> file_array;

  FileModel({required this.file_array});

  factory FileModel.fromJson(Map<String, dynamic> json) =>
      _$FileModelFromJson(json);
  Map<String, dynamic> toJson() => _$FileModelToJson(this);
}