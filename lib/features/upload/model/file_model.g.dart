// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FileModel _$FileModelFromJson(Map<String, dynamic> json) => FileModel(
  file_array:
      (json['file_array'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$FileModelToJson(FileModel instance) => <String, dynamic>{
  'file_array': instance.file_array,
};
