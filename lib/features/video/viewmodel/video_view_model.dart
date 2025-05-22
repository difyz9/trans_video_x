import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trans_video_x/features/video/repository/video_service_repository.dart';
import '../model/video_model.dart';

final videoViewModelProvider =
    StateNotifierProvider<VideoViewModel, AsyncValue<VideoListResponse>>(
  (ref) => VideoViewModel(ref),
);

class VideoViewModel extends StateNotifier<AsyncValue<VideoListResponse>> {
  final Ref ref;
  int _currentPage = 1;
  final int _pageSize = 12;
  bool _isLoadingMore = false;

  VideoViewModel(this.ref) : super(const AsyncValue.loading()) {
    fetchVideoList();
  }

  bool get isLoadingMore => _isLoadingMore;

  Future<void> fetchVideoList() async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(videoServiceRepositoryProvider);
      final response = await repository.getVideoList(_currentPage, _pageSize);
      print('Video list response: ${response.data}');
      state = AsyncValue.data(response);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<bool> updateVideoStatus(String videoId, String status) async {
    try {
      final repository = ref.read(videoServiceRepositoryProvider);
      final resp = await repository.updateVideoStatus(videoId, status);
      if (resp.code == 200){
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating video status: $e');
      return false;
    }
  }

  Future<void> loadMoreVideos() async {
    if (_isLoadingMore) return;

    _isLoadingMore = true;
    // Update the current state to trigger a rebuild without changing the data
    // This allows the UI to reflect the loading state
    state = state;

    try {
      final repository = ref.read(videoServiceRepositoryProvider);
      final newResponse = await repository.getVideoList(_currentPage + 1, _pageSize);

      if (newResponse.data!.isEmpty) {
        _isLoadingMore = false;
        state = state; // Update again to reflect loading state change
        return;
      }

      _currentPage++;

      state.whenData((currentResponse) {
        final updatedList = [
          ...currentResponse.data!,
          ...newResponse.data!,
        ];
        final updatedData = currentResponse.copyWith(data: updatedList);
        final updatedResponse = currentResponse.copyWith(data: updatedData.data!);
        state = AsyncValue.data(updatedResponse);
      });
    } catch (e) {
      print('Error loading more videos: $e');
    } finally {
      _isLoadingMore = false;
      state = state; // Update again to reflect loading state change
    }
  }
}