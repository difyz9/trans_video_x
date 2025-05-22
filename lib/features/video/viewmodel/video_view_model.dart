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
  final int _pageSize = 8; // 减小页面大小，降低服务器负载
  bool _isLoadingMore = false;
  bool _hasReachedEnd = false;
  int _failedAttempts = 0;
  static const int _maxRetryAttempts = 3;

  VideoViewModel(this.ref) : super(const AsyncValue.loading()) {
    fetchVideoList();
  }

  bool get isLoadingMore => _isLoadingMore;
  bool get hasReachedEnd => _hasReachedEnd;

  Future<void> fetchVideoList() async {
    state = const AsyncValue.loading();
    try {
      // 重置页码和终点状态
      _currentPage = 1;
      _hasReachedEnd = false;
      _failedAttempts = 0;

      final repository = ref.read(videoServiceRepositoryProvider);
      final response = await repository.getVideoList(_currentPage, _pageSize);

      // 检查是否已经没有更多数据
      if (response.data == null || response.data!.isEmpty || response.data!.length < _pageSize) {
        _hasReachedEnd = true;
      }

      state = AsyncValue.data(response);
    } catch (e) {
      print('Error fetching video list: $e');
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
    if (_isLoadingMore || _hasReachedEnd) return;
    if (_failedAttempts >= _maxRetryAttempts) {
      print('达到最大重试次数，不再尝试加载更多内容');
      _hasReachedEnd = true;
      state = state;
      return;
    }

    _isLoadingMore = true;
    // Update the current state to trigger a rebuild without changing the data
    // This allows the UI to reflect the loading state
    state = state;

    try {
      final repository = ref.read(videoServiceRepositoryProvider);
      final newResponse = await repository.getVideoList(_currentPage + 1, _pageSize);

      if (newResponse.data == null || newResponse.data!.isEmpty) {
        _hasReachedEnd = true;
        _isLoadingMore = false;
        state = state; // Update again to reflect loading state change
        return;
      }

      // 如果返回的数据少于页大小，说明已经到达末尾
      if (newResponse.data!.length < _pageSize) {
        _hasReachedEnd = true;
      }

      _currentPage++;
      _failedAttempts = 0; // 成功加载后重置失败计数

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
      _failedAttempts++;
      print('Error loading more videos (attempt $_failedAttempts/$_maxRetryAttempts): $e');
      
      // 如果在最后一次尝试后仍然失败，标记为已到达末尾
      if (_failedAttempts >= _maxRetryAttempts) {
        _hasReachedEnd = true;
      }
    } finally {
      _isLoadingMore = false;
      state = state; // Update again to reflect loading state change
    }
  }
}