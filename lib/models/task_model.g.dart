// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

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
