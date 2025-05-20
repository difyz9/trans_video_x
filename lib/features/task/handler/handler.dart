import 'task_state_manager.dart';
import 'video_processing_client.dart' show StatusUpdateCallback;


abstract class Command {
  Future<void> execute(TaskStateManager stateManager);
}

abstract class TaskHandler {
  TaskHandler? _nextHandler;

  TaskHandler setNext(TaskHandler handler) {
    _nextHandler = handler;
    return handler;
  }

  Future<void> handleRequest(TaskStateManager stateManager, StatusUpdateCallback? onStatusUpdate) async {
    await process(stateManager, onStatusUpdate);

    if (stateManager.hasError) {
      print("Error detected after ${this.runtimeType}. Halting chain.");
      return;
    }

    if (_nextHandler != null) {
      await _nextHandler!.handleRequest(stateManager, onStatusUpdate);
    }
  }

  Future<void> process(TaskStateManager stateManager, StatusUpdateCallback? onStatusUpdate);
}




