import 'package:trans_video_x/features/task/handler/video_processing_client.dart';
import 'package:trans_video_x/features/task/utils/ffmpeg_wrapper.dart';
import '../model/task_status.dart'; // Required for TaskStatus
import 'handler.dart';
import 'task_state_manager.dart';
import 'video_processing_client.dart' show StatusUpdateCallback;

class ExtractAudioHandler extends TaskHandler {
  ExtractAudioHandler();

  @override
  Future<void> process(TaskStateManager stateManager, StatusUpdateCallback? onStatusUpdate) async {
    onStatusUpdate?.call(TaskStatus.extractingAudio, "Starting audio extraction");
    print('Extracting audio...');

    try {
      final String? videoPath = stateManager.processedVideoPath;
      if (videoPath == null || videoPath.isEmpty) {
        throw Exception('Video path not found for extracting audio.');
      }

      
      FFmpegWrapper.extractAudioFromVideo(stateManager.inputVideoPath, stateManager.originalMp3);
  
    } catch (e, s) {
      final errorMessage = 'Failed to extract audio: ${e.toString()}';
      print('$errorMessage\n$s');
      stateManager.setError(errorMessage, s);
      onStatusUpdate?.call(TaskStatus.error, errorMessage);
    }
  }
}
