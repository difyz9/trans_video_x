import 'package:trans_video_x/features/task/handler/video_processing_client.dart';
import '../model/task_status.dart'; // Required for TaskStatus
import 'handler.dart';
import 'task_state_manager.dart';
import 'video_processing_client.dart' show StatusUpdateCallback;
import 'package:trans_video_x/features/task/utils/yt_dlp_wrapper.dart';
import 'package:trans_video_x/features/task/model/yt_dlp_params.dart';
import 'package:trans_video_x/features/task/model/yt_dlp_response.dart';





class DownloadVideoHandler extends TaskHandler {
  // Constructor is now simpler
  DownloadVideoHandler();

  @override
  Future<void> process(TaskStateManager stateManager, StatusUpdateCallback? onStatusUpdate) async {
    onStatusUpdate?.call(TaskStatus.downloading, "Starting video download");
    print('Downloading video from: ${stateManager.videoUrl} ...');

    try {
      final ytdlp = YtDlpWrapper();

      YtDlpParams parametros = YtDlpParams(
        null,       // _id
        "mp4",      // _extensao
        "",         // _formato (set to empty string for video download)
        "1080p30",  // _resolucaoFps
      );


      print("VideoUrl ---------------> ${stateManager.videoUrl}");

      final result = await ytdlp.downloadVideo(
        stateManager.videoUrl,
        stateManager.currentDir,
        parametros: parametros,
      );

      if (result.status == YtDlpStatus.success) {
        // Assuming result.message is non-null and contains the path on success
        stateManager.processedVideoPath = result.message;
        print('Video downloaded to: ${stateManager.processedVideoPath}');
        onStatusUpdate?.call(TaskStatus.downloading, "Video download completed");
      } else if (result.status == YtDlpStatus.info &&
                 result.message != null &&
                 result.message!.toLowerCase().contains("este arquivo já existe")) {
        // File already exists, use the expected input path.
        // Ideally, YtDlpWrapper would return the path of the existing file in result.message.
        stateManager.processedVideoPath = stateManager.inputVideoPath;
        print('Video already exists at: ${stateManager.processedVideoPath}. Using existing file.');
        onStatusUpdate?.call(TaskStatus.downloading, "Video download completed (already exists)");
      } else {
        final errorMessage = 'Failed to download video: ${result.message} (Status: ${result.status})';
        print(errorMessage);
        stateManager.setError(errorMessage, StackTrace.current);
        onStatusUpdate?.call(TaskStatus.error, errorMessage);
        return; 
      }
    } catch (e, s) {
      final errorMessage = 'Failed to download video: ${e.toString()}';
      print('$errorMessage\n$s');
      stateManager.setError(errorMessage, s);
      onStatusUpdate?.call(TaskStatus.error, errorMessage);
    }
  }
}
