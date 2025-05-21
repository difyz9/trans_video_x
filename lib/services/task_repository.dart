// lib/services/task_repository.dart
import 'package:trans_video_x/models/task_model.dart';
import 'package:trans_video_x/services/post_service.dart';

class TaskRepository {
  final PostService _postService;

  TaskRepository(this._postService);

  Future<ApiResponseModel> postNewTask(TaskModel task) async { // Update return type
    try {
      print('TaskRepository: Posting task ${task.id}');
      final response = await _postService.postTask(task);
      print('TaskRepository: Task ${task.id} posted successfully. Response: ${response.message}, Code: ${response.code}');
      // You might want to check response.code == 200 here before considering it a success
      if (response.code == 200) {
        return response;
      } else {
        throw Exception('Backend error: ${response.message} (Code: ${response.code})');
      }
    } catch (e) {
      print('Error in TaskRepository while posting task ${task.id}: $e');
      rethrow;
    }
  }
}