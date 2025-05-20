import 'package:trans_video_x/features/task/handler/video_processing_client.dart' show StatusUpdateCallback;
import 'package:trans_video_x/features/task/utils/ffmpeg_wrapper.dart';
import '../model/task_status.dart'; // Required for TaskStatus
import 'handler.dart';
import 'task_state_manager.dart';

class ExtractFramesHandler extends TaskHandler {
  ExtractFramesHandler();

  @override
  Future<void> process(TaskStateManager stateManager, StatusUpdateCallback? onStatusUpdate) async {
    onStatusUpdate?.call(TaskStatus.extractingFrames, "Starting frame extraction");
    print('Extracting frames...');

    try {
      final String? videoPath = stateManager.processedVideoPath;
      if (videoPath == null || videoPath.isEmpty) {
        throw Exception('Video path not found for extracting frames.');
      }


      FFmpegWrapper.extractFrameFromVideo(stateManager.inputVideoPath, stateManager.imageCover, "1");

      // Simulate frame extraction
      // await Future.delayed(const Duration(seconds: 3));
      // stateManager.extractedFramesPath = 'temp/extracted_frames/';
      // stateManager.extractedImageFiles = ['frame1.jpg', 'frame2.jpg', 'frame3.jpg'];
      // print('Frames extracted to: ${stateManager.extractedFramesPath}');

      
      onStatusUpdate?.call(TaskStatus.extractingFrames, "Frame extraction completed");
    } catch (e, s) {
      final errorMessage = 'Failed to extract frames: ${e.toString()}';
      print('$errorMessage\n$s');
      stateManager.setError(errorMessage, s);
      onStatusUpdate?.call(TaskStatus.error, errorMessage);
    }
  }
}