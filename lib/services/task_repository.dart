// lib/services/task_repository.dart
import 'package:trans_video_x/models/task_model.dart';
import 'package:trans_video_x/services/post_service.dart';

class TaskRepository {
  final PostService _postService;

  TaskRepository(this._postService);

  Future<void> postNewTask(TaskModel task) async {
    try {
      await _postService.postTask(task);
      // You could add more logic here, like logging or specific error handling
      print('Task ${task.id} submitted via repository.');
    } catch (e) {
      // Handle or rethrow the error as appropriate for your app's error strategy
      print('Error in TaskRepository while posting task ${task.id}: $e');
      rethrow; // Rethrowing allows the ViewModel to catch and handle it
    }
  }
}
