import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/video_model.dart';
import '../model/video_info_model.dart';
import 'package:trans_video_x/core/constants/app_constants.dart';
import 'package:trans_video_x/core/api/dio_provider.dart';
import 'dart:convert';

part 'video_api_service.g.dart';

@RestApi(baseUrl: "${AppConstants.baseUrl}")
abstract class VideoApiService {
  factory VideoApiService(Dio dio, {String baseUrl}) = _VideoApiService;

  @GET("/media/video/list")
  Future<VideoListResponse> getVideoList({
      @Query("pageNum") required int pageNum,
    @Query("pageSize") required int pageSize,
    @Query("status") String status = "200",
  }
 
  );

 @GET('/media/video/{videoId}')
  Future<VideoDetailResponse> getVideoDetail(
    @Path('videoId') String videoId,
  );

 @PUT('/media/video')
  Future<VideoStatusResponse> updateVideoStatus(
    @Body() VideoStatusRequest request,
  );
}

Provider<VideoApiService> videoApiServiceProvider = Provider((ref) {
  // Use the dioProvider to get a configured Dio instance
  final dio = ref.watch(dioProvider);
  
  // Add an interceptor to include the auth token from secure storage
  

  
  return VideoApiService(dio);
});
