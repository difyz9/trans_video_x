// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_info_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VideoInfoImpl _$$VideoInfoImplFromJson(Map<String, dynamic> json) =>
    _$VideoInfoImpl(
      code: (json['code'] as num).toInt(),
      data: VideoData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$VideoInfoImplToJson(_$VideoInfoImpl instance) =>
    <String, dynamic>{
      'code': instance.code,
      'data': instance.data,
    };

_$VideoDataImpl _$$VideoDataImplFromJson(Map<String, dynamic> json) =>
    _$VideoDataImpl(
      title: json['title'] as String,
      videoUrl: json['videoUrl'] as String,
      videoId: json['videoId'] as String,
      srtUrl: json['srtUrl'] as String,
      imgUrl: json['imgUrl'] as String,
    );

Map<String, dynamic> _$$VideoDataImplToJson(_$VideoDataImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'videoUrl': instance.videoUrl,
      'videoId': instance.videoId,
      'srtUrl': instance.srtUrl,
      'imgUrl': instance.imgUrl,
    };

_$SubtitleModelImpl _$$SubtitleModelImplFromJson(Map<String, dynamic> json) =>
    _$SubtitleModelImpl(
      id: (json['id'] as num).toInt(),
      start: json['start'] as String,
      end: json['end'] as String,
      text: json['text'] as String,
      audio: json['audio'] as String,
    );

Map<String, dynamic> _$$SubtitleModelImplToJson(_$SubtitleModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'start': instance.start,
      'end': instance.end,
      'text': instance.text,
      'audio': instance.audio,
    };

_$VideoUpdateImpl _$$VideoUpdateImplFromJson(Map<String, dynamic> json) =>
    _$VideoUpdateImpl(
      code: (json['code'] as num).toInt(),
      data: json['data'] as bool,
    );

Map<String, dynamic> _$$VideoUpdateImplToJson(_$VideoUpdateImpl instance) =>
    <String, dynamic>{
      'code': instance.code,
      'data': instance.data,
    };
