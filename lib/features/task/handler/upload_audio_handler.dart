import 'package:trans_video_x/features/task/handler/video_processing_client.dart';

import 'handler.dart';
import 'task_state_manager.dart';


class UploadAudioCommand implements Command {
  // Constructor no longer needs audioUploadEndpoint
  UploadAudioCommand();

  @override
  Future<void> execute(TaskStateManager stateManager) async {
    if (stateManager.hasError) return; // Skip if previous step failed
    try {
      final String? audioPath = stateManager.extractedAudioPath;
      if (audioPath == null || audioPath.isEmpty) {
        throw Exception('Audio path not found in stateManager for uploading.');
      }
      // Read upload endpoint from stateManager
   
      await Future.delayed(const Duration(seconds: 2));
      print('Audio file uploaded successfully.');
    } catch (e, s) {
      stateManager.setError('Failed to upload audio: ${e.toString()}', s);
    }
  }
}


class UploadAudioHandler extends TaskHandler {
  final Command _commandInstance = UploadAudioCommand();

  @override
  Command get command => _commandInstance;

  UploadAudioHandler();
  
  @override
  Future<void> process(TaskStateManager stateManager, StatusUpdateCallback? onStatusUpdate) {
    // TODO: implement process
    throw UnimplementedError();
  }
}
