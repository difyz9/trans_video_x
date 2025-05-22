// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VideoListResponseImpl _$$VideoListResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$VideoListResponseImpl(
      total: (json['total'] as num).toInt(),
      rows: json['rows'] as List<dynamic>?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => VideoItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      code: (json['code'] as num).toInt(),
      msg: json['msg'] as String,
    );

Map<String, dynamic> _$$VideoListResponseImplToJson(
        _$VideoListResponseImpl instance) =>
    <String, dynamic>{
      'total': instance.total,
      'rows': instance.rows,
      'data': instance.data,
      'code': instance.code,
      'msg': instance.msg,
    };

_$VideoItemImpl _$$VideoItemImplFromJson(Map<String, dynamic> json) =>
    _$VideoItemImpl(
      createBy: json['createBy'] as String?,
      createTime: json['createTime'] as String,
      id: json['id'] as String,
      userId: json['userId'] as String?,
      status: json['status'] as String,
      title: json['title'] as String?,
      videoUrl: json['videoUrl'] as String?,
      videoId: json['videoId'] as String,
      mediaUrl: json['mediaUrl'] as String?,
      zhSrt: json['zhSrt'] as String,
      imgUrl: json['imgUrl'] as String,
    );

Map<String, dynamic> _$$VideoItemImplToJson(_$VideoItemImpl instance) =>
    <String, dynamic>{
      'createBy': instance.createBy,
      'createTime': instance.createTime,
      'id': instance.id,
      'userId': instance.userId,
      'status': instance.status,
      'title': instance.title,
      'videoUrl': instance.videoUrl,
      'videoId': instance.videoId,
      'mediaUrl': instance.mediaUrl,
      'zhSrt': instance.zhSrt,
      'imgUrl': instance.imgUrl,
    };

_$VideoDetailResponseImpl _$$VideoDetailResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$VideoDetailResponseImpl(
      msg: json['msg'] as String,
      code: (json['code'] as num).toInt(),
      data: VideoItem.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$VideoDetailResponseImplToJson(
        _$VideoDetailResponseImpl instance) =>
    <String, dynamic>{
      'msg': instance.msg,
      'code': instance.code,
      'data': instance.data,
    };

_$VideoStatusRequestImpl _$$VideoStatusRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$VideoStatusRequestImpl(
      id: json['id'] as String,
      status: json['status'] as String,
    );

Map<String, dynamic> _$$VideoStatusRequestImplToJson(
        _$VideoStatusRequestImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
    };

_$VideoStatusResponseImpl _$$VideoStatusResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$VideoStatusResponseImpl(
      msg: json['msg'] as String,
      code: (json['code'] as num).toInt(),
    );

Map<String, dynamic> _$$VideoStatusResponseImplToJson(
        _$VideoStatusResponseImpl instance) =>
    <String, dynamic>{
      'msg': instance.msg,
      'code': instance.code,
    };
