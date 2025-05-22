import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:async/async.dart';
import 'package:logger/logger.dart';
import '../model/video_model.dart';
import '../model/video_info_model.dart';
import '../repository/video_service_repository.dart';

final videoInfoViewModelProvider =
    StateNotifierProvider<VideoInfoViewModel, AsyncValue<VideoItem>>((ref) {
  final repository = ref.watch(videoServiceRepositoryProvider);
  return VideoInfoViewModel(repository);
});

class VideoInfoViewModel extends StateNotifier<AsyncValue<VideoItem>> {
  final VideoServiceRepository _repository;
  final Logger _logger = Logger();
  CancelableOperation<VideoInfo>? _currentFetch;

  VideoInfoViewModel(this._repository) : super(const AsyncValue.loading());

  Future<void> fetchVideoInfo(String videoId) async {
    state = const AsyncValue.loading();
    try {
      final videoInfo = await _repository.fetchVideoDetail(videoId);
      state = AsyncValue.data(videoInfo.data);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Method to cancel any ongoing fetch operation when the screen is disposed
  void cancelFetch() {
    _logger.d("VideoInfoViewModel: Canceling fetch operation");
    _currentFetch?.cancel();
    _currentFetch = null;
  }

  @override
  void dispose() {
    _logger.d("VideoInfoViewModel: Disposing");
    cancelFetch();
    super.dispose();
  }
}
