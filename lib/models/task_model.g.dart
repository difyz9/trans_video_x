// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskModelAdapter extends TypeAdapter<TaskModel> {
  @override
  final int typeId = 0;

  @override
  TaskModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskModel(
      id: fields[0] as String,
      name: fields[1] as String,
      path: fields[2] as String,
      size: fields[3] as int,
      formattedSize: fields[4] as String,
      type: fields[5] as String,
      uploadTime: fields[6] as String,
      sourceLanguage: fields[7] as String,
      targetLanguage: fields[8] as String,
      status: fields[9] as String,
      cosObjectKey: fields[10] as String,
      downloadUrl: fields[11] as String?,
      errorMessage: fields[12] as String?,
    )..syncStatusString = fields[13] as String;
  }

  @override
  void write(BinaryWriter writer, TaskModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.path)
      ..writeByte(3)
      ..write(obj.size)
      ..writeByte(4)
      ..write(obj.formattedSize)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.uploadTime)
      ..writeByte(7)
      ..write(obj.sourceLanguage)
      ..writeByte(8)
      ..write(obj.targetLanguage)
      ..writeByte(9)
      ..write(obj.status)
      ..writeByte(10)
      ..write(obj.cosObjectKey)
      ..writeByte(11)
      ..write(obj.downloadUrl)
      ..writeByte(12)
      ..write(obj.errorMessage)
      ..writeByte(13)
      ..write(obj.syncStatusString);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskModel _$TaskModelFromJson(Map<String, dynamic> json) => TaskModel(
      id: json['id'] as String,
      name: json['name'] as String,
      path: json['path'] as String,
      size: (json['size'] as num).toInt(),
      formattedSize: json['formattedSize'] as String,
      type: json['type'] as String,
      uploadTime: json['uploadTime'] as String,
      sourceLanguage: json['sourceLanguage'] as String,
      targetLanguage: json['targetLanguage'] as String,
      status: json['status'] as String,
      cosObjectKey: json['cosObjectKey'] as String,
      downloadUrl: json['downloadUrl'] as String?,
      errorMessage: json['errorMessage'] as String?,
    )
      ..syncStatusString = json['syncStatusString'] as String
      ..syncStatus = $enumDecode(_$SyncStatusEnumMap, json['syncStatus']);

Map<String, dynamic> _$TaskModelToJson(TaskModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'path': instance.path,
      'size': instance.size,
      'formattedSize': instance.formattedSize,
      'type': instance.type,
      'uploadTime': instance.uploadTime,
      'sourceLanguage': instance.sourceLanguage,
      'targetLanguage': instance.targetLanguage,
      'status': instance.status,
      'cosObjectKey': instance.cosObjectKey,
      'downloadUrl': instance.downloadUrl,
      'errorMessage': instance.errorMessage,
      'syncStatusString': instance.syncStatusString,
      'syncStatus': _$SyncStatusEnumMap[instance.syncStatus]!,
    };

const _$SyncStatusEnumMap = {
  SyncStatus.pending: 'pending',
  SyncStatus.synced: 'synced',
  SyncStatus.failed: 'failed',
};
