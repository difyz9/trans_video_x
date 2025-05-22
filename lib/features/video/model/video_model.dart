import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_model.freezed.dart';
part 'video_model.g.dart';



@freezed
class VideoListResponse with _$VideoListResponse {
  const factory VideoListResponse({
    required int total,
    List<dynamic>? rows,
    required List<VideoItem>? data,
    required int code,
    required String msg,
  }) = _VideoListResponse;

  factory VideoListResponse.fromJson(Map<String, dynamic> json) =>
      _$VideoListResponseFromJson(json);
}

@freezed
class VideoItem with _$VideoItem {
  const factory VideoItem({
     String? createBy,
    required String createTime,

    required String id,
    String? userId,
    required String status,
    String? title,
    String? videoUrl,
    required String videoId,
    String? mediaUrl,
    required String zhSrt,
    required String imgUrl,
  }) = _VideoItem;

  factory VideoItem.fromJson(Map<String, dynamic> json) =>
      _$VideoItemFromJson(json);
}


@freezed
class VideoDetailResponse with _$VideoDetailResponse {
  const factory VideoDetailResponse({
    required String msg,
    required int code,
    required VideoItem data,
  }) = _VideoDetailResponse;

  factory VideoDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$VideoDetailResponseFromJson(json);
}


@freezed
class VideoStatusRequest with _$VideoStatusRequest {
  const factory VideoStatusRequest({
    required String id,
    required String status,
  }) = _VideoStatusRequest;

  factory VideoStatusRequest.fromJson(Map<String, dynamic> json) =>
      _$VideoStatusRequestFromJson(json);
}

@freezed
class VideoStatusResponse with _$VideoStatusResponse {
  const factory VideoStatusResponse({
    required String msg,
    required int code,
  }) = _VideoStatusResponse;

  factory VideoStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$VideoStatusResponseFromJson(json);
}