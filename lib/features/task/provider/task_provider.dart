import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trans_video_x/models/add_url_model.dart';
import '../model/task_status.dart';
import '../handler/video_processing_client.dart';
import '../handler/task_state_manager.dart';

// Tracks all URL processing tasks
final taskStatusProvider = StateNotifierProvider<TaskStatusNotifier, Map<String, VideoTaskStatus>>((ref) {
  return TaskStatusNotifier();
});

// Tracks if a poll operation is currently in progress
final isPollingProvider = StateProvider<bool>((ref) => false);

class TaskStatusNotifier extends StateNotifier<Map<String, VideoTaskStatus>> {
  TaskStatusNotifier() : super({});
  Timer? _pollingTimer;
  bool _isProcessing = false;

  // Updates task status for a specific URL
  void updateTaskStatus(String urlId, TaskStatus status, [String? message]) {
    state = {
      ...state,
      urlId: state.containsKey(urlId)
          ? state[urlId]!.copyWith(status: status, message: message)
          : VideoTaskStatus(
              urlId: urlId,
              status: status,
              message: message,
            ),
    };
  }

  // Process a single URL
  Future<void> processUrl(AddUrlModel urlVo, {
    required String audioUploadEndpoint,
    required String framesUploadEndpoint,
  }) async {
    if (urlVo.id == null || urlVo.url == null) return;
    
    // Update status to pending
    updateTaskStatus(urlVo.id!, TaskStatus.pending, 'Preparing to process');
    
    // Create video processing client 
    final client = VideoProcessingClient(
      initialVideoUrl: urlVo.url!,
      framesPerSecond: 1, // Default value
      audioBitrate: '128k', // Default value
      audioUploadEndpoint: audioUploadEndpoint,
      framesUploadEndpoint: framesUploadEndpoint,
      onStatusUpdate: (status, message) {
        updateTaskStatus(urlVo.id!, status, message);
      },
    );
    
    try {
      // Process the video
      await client.startProcessing();
      updateTaskStatus(urlVo.id!, TaskStatus.completed, 'Processing completed');
    } catch (e) {
      updateTaskStatus(urlVo.id!, TaskStatus.error, 'Error: ${e.toString()}');
    }
  }

  // Check for pending URLs and process them
  Future<void> checkAndProcessPendingUrls({
    required Box<AddUrlModel> urlBox,
    required String audioUploadEndpoint,
    required String framesUploadEndpoint,
  }) async {
    if (_isProcessing) return; // Don't start if already processing
    _isProcessing = true;
    
    try {
      if (urlBox.isEmpty) {
        return; // No URLs to process
      }
      
      // Find URLs that haven't been processed yet
      for (int i = 0; i < urlBox.length; i++) {
        final urlVo = urlBox.getAt(i);
        if (urlVo == null || urlVo.id == null) continue;
        
        // Skip if already processed or in progress
        if (state.containsKey(urlVo.id!) && 
            (state[urlVo.id!]!.status == TaskStatus.completed || 
             state[urlVo.id!]!.status == TaskStatus.error)) {
          continue;
        }
        
        // Process this URL
        await processUrl(
          urlVo,
          audioUploadEndpoint: audioUploadEndpoint,
          framesUploadEndpoint: framesUploadEndpoint,
        );
        
        // Process one URL at a time, then return
        break;
      }
    } finally {
      _isProcessing = false;
    }
  }
  
  // Start polling for new URLs
  void startPolling({
    required Box<AddUrlModel> urlBox,
    required String audioUploadEndpoint,
    required String framesUploadEndpoint,
  }) {
    // Cancel any existing timer
    stopPolling();
    
    // Create a new polling timer
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      checkAndProcessPendingUrls(
        urlBox: urlBox,
        audioUploadEndpoint: audioUploadEndpoint,
        framesUploadEndpoint: framesUploadEndpoint,
      );
    });
  }
  
  // Stop polling
  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }
  
  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
