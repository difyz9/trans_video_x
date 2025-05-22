import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'video_info_model.freezed.dart';
part 'video_info_model.g.dart';

@freezed
class VideoInfo with _$VideoInfo {
  const factory VideoInfo({
    required int code,
    required VideoData data,
  }) = _VideoInfo;

  factory VideoInfo.fromJson(Map<String, dynamic> json) =>
      _$VideoInfoFromJson(json);
}

@freezed
class VideoData with _$VideoData {
  const factory VideoData({
    required String title,
    required String videoUrl,
    required String videoId,
    required String srtUrl,
    required String imgUrl,
    // required List<SubtitleModel> subtitles

  }) = _VideoData;

  factory VideoData.fromJson(Map<String, dynamic> json) =>
      _$VideoDataFromJson(json);
}

@freezed
class SubtitleModel with _$SubtitleModel {
  const factory SubtitleModel({
    required int id,
    required String start,
    required String end,
    required String text,
    required String audio,
  }) = _SubtitleModel;

  factory SubtitleModel.fromJson(Map<String, dynamic> json) =>
      _$SubtitleModelFromJson(json);
}

@freezed
class VideoUpdate with _$VideoUpdate {
  const factory VideoUpdate({
    required int code,
    required bool data,
  }) = _VideoUpdate;

  factory VideoUpdate.fromJson(Map<String, dynamic> json) =>
      _$VideoUpdateFromJson(json);
}