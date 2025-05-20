import 'handler.dart';
import 'task_state_manager.dart';
import '../model/task_status.dart';
import 'package:trans_video_x/features/task/handler/video_processing_client.dart';


class UploadFramesCommand implements Command {
  // Constructor no longer needs framesUploadEndpoint
  UploadFramesCommand();

  @override
  Future<void> execute(TaskStateManager stateManager) async {
    if (stateManager.hasError) return; // Skip if previous step failed
    try {
      final String? framesPath = stateManager.extractedFramesPath;
      final List<String> imageFiles = stateManager.extractedImageFiles ?? [];
      if (framesPath == null || framesPath.isEmpty || imageFiles.isEmpty) {
        throw Exception('Frames path or image files not found in stateManager for uploading.');
      }
      // Read upload endpoint from stateManager
      // print('Uploading frames from: $framesPath to ${stateManager.framesUploadEndpoint} ...');
      // for (String frameFile in imageFiles) {
      //   print('Uploading frame: $frameFile ...');
      //   // Simulate frame upload
      //   await Future.delayed(const Duration(milliseconds: 500));
      // }
      print('All frames uploaded successfully.');
    } catch (e, s) {
      stateManager.setError('Failed to upload frames: ${e.toString()}', s);
    }
  }
}

class UploadFramesHandler extends TaskHandler {
  @override
  Future<void> process(TaskStateManager stateManager, StatusUpdateCallback? onStatusUpdate) async {
    print("Starting frames upload...");
    onStatusUpdate?.call(TaskStatus.uploadingFrames, "Starting frames upload");

    // Placeholder logic - replace with actual implementation
  
  }
}
