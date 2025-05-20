import 'handler.dart';
import 'task_state_manager.dart';
import '../model/task_status.dart';

// Concrete Handlers
import 'download_video_handler.dart';
import 'extract_frame_handler.dart';
import 'extract_audio_handler.dart';
import 'upload_audio_handler.dart';
import 'upload_frames_handler.dart';
import 'package:trans_video_x/core/constants/app_config.dart';

typedef StatusUpdateCallback = void Function(TaskStatus status, String message);

class VideoProcessingClient {
  TaskHandler? _chain;
  final TaskStateManager _stateManager;
  final StatusUpdateCallback? onStatusUpdate;

  VideoProcessingClient({
    required String initialVideoUrl,
    int? framesPerSecond,
    String? audioBitrate,
    required String audioUploadEndpoint,
    required String framesUploadEndpoint,
    this.onStatusUpdate,
  }) : _stateManager = TaskStateManager(
          projectRoot: AppConfig.instance.destino,
          videoUrl: initialVideoUrl,
        ) {
    _setupChain();
  }

  void _setupChain() {
    final downloadHandler = DownloadVideoHandler();
    final extractFramesHandler = ExtractFramesHandler();
    final extractAudioHandler = ExtractAudioHandler();
    final uploadAudioHandler = UploadAudioHandler();
    final uploadFramesHandler = UploadFramesHandler();

    downloadHandler
        .setNext(extractFramesHandler)
        .setNext(extractAudioHandler)
        .setNext(uploadAudioHandler)
        .setNext(uploadFramesHandler);

    _chain = downloadHandler;
  }

// String caminho = AppConfig.instance.destino;
  Future<void> startProcessing() async {
    if (_chain == null) {
      print("Error: Processing chain is not set up.");
      onStatusUpdate?.call(TaskStatus.error, "Processing chain is not set up.");
      return;
    }

    print("_stateManager.toString() --- > ${_stateManager.toString()}");

    print("Starting video processing for URL: ${_stateManager.videoUrl}");

    try {
      await _chain!.handleRequest(_stateManager, onStatusUpdate);

      if (_stateManager.hasError) {
        // Error message and status update should have been handled by the failing handler.
        print("Video processing failed: ${_stateManager.errorMessage}");
      } else {
        onStatusUpdate?.call(TaskStatus.completed, "Processing completed successfully");
        print("Video processing finished successfully.");
      }
    } catch (e, s) {
      print("An unexpected error occurred in startProcessing: $e\n$s");
      _stateManager.setError("An unexpected error occurred: $e");
      onStatusUpdate?.call(TaskStatus.error, _stateManager.errorMessage!);
    }
    
    print("Final state: ${_stateManager.toString()}");
  }
}
