import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/video_api_service.dart';
import '../model/video_info_model.dart';
import 'package:logger/logger.dart';

import '../model/video_model.dart';

class VideoServiceRepository {
    final Logger _logger = Logger();

  final VideoApiService _service;

  VideoServiceRepository(this._service);


  Future<VideoListResponse> getVideoList(int pageNum, int pageSize) async {
    try {
      return await _service.getVideoList( pageNum: pageNum,pageSize:pageSize);
    } on DioException catch (e) {
      throw Exception("Failed to load video list: ${e.message}");
    }
  }

  Future<VideoDetailResponse> fetchVideoDetail(String videoId) async {
    try {
      final result = await _service.getVideoDetail(videoId);
      _logger.d("VideoRepository: Successfully fetched video info for ID: $videoId");
      return result;
    } on DioException catch (e) {

      _logger.e("VideoRepository: Unexpected error: $e");
      // return _getFallbackVideoInfo(videoId);
      throw Exception("Failed to load video info: ${e.message}");
    }
  }

  Future<VideoStatusResponse> updateVideoStatus(String id, String status) async {
    try {
            final request = VideoStatusRequest(id: id, status: status);

      final result = await _service.updateVideoStatus(request);
      _logger.d("VideoRepository: Successfully updated video ID: $id with status: $status");
      
      // Convert the Map response to a boolean
     
      return result;
    } on DioException catch (e) {
      _logger.e("VideoRepository: Failed to update video status: $e");
      throw Exception("Failed to update video status: ${e.message}");
    }
  }

}

// Renamed provider to avoid conflicts with the one in repository/video_repository.dart
final videoServiceRepositoryProvider = Provider<VideoServiceRepository>((ref) {
  final videoApiService = ref.watch(videoApiServiceProvider);
  return VideoServiceRepository(videoApiService);
});
