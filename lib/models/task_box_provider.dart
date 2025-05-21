
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'task_model.dart';
import 'dart:async'; // Import for StreamSubscription
import 'package:trans_video_x/core/api/dio_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trans_video_x/core/api/dio_provider.dart';
import 'package:trans_video_x/services/post_service.dart';
import 'package:trans_video_x/services/task_repository.dart'; 


final taskBoxProvider = FutureProvider<Box<TaskModel>>((ref) async {
  // Ensure Hive is initialized and adapter registered in main.dart
  return await Hive.openBox<TaskModel>('tasksBox');
});

final taskPostProvider = Provider((ref) {
   // Configure Dio as needed (interceptors, etc.)
     final dio = ref.watch(dioProvider); 

  return PostService(dio); // Pass the Dio instance to PostService
  // Ensure PostService is properly set up to use the Dio instance
});

final taskRepositoryProvider = Provider((ref) {
  return TaskRepository(ref.watch(taskPostProvider)); // Correctly instantiate TaskRepository
});

class TaskSyncViewModel extends StateNotifier<void> { // Or your preferred state type
  final Box<TaskModel> _taskBox;
  final TaskRepository _taskRepository;
  StreamSubscription? _hiveSubscription;

  TaskSyncViewModel(this._taskBox, this._taskRepository) : super(null) {
    _listenToHiveChanges();
    _processPendingTasks(); // Process any tasks that were pending from a previous session
  }

  void _listenToHiveChanges() {
    _hiveSubscription = _taskBox.watch().listen((event) {
      if (!event.deleted && event.value != null) {
        final task = event.value as TaskModel;
        print("==========================================: ${task.id}"); // Debugging line
        // Only process if it's newly added and pending sync
        print("==========================================: ${task.syncStatus}"); // Debugging line

        // This condition might need adjustment if tasks can be added with other statuses
        // and then later marked as pending. For now, assumes new tasks are pending.
        if (task.syncStatus == SyncStatus.pending) {
          _sendTaskToBackend(task);
        }
      }
    });
  }

  // Method to process tasks that might have been added while the app was closed
  // or if a previous sync attempt failed.
  Future<void> _processPendingTasks() async {
    final pendingTasks = _taskBox.values.where((task) => task.syncStatus == SyncStatus.pending).toList();
    for (var task in pendingTasks) {
      await _sendTaskToBackend(task);
    }
  }

  Future<void> _sendTaskToBackend(TaskModel task) async {
    try {
      await _taskRepository.postNewTask(task);
      print('Task ${task.id} successfully sent to backend.');
      // Update status in Hive after successful send
      task.syncStatus = SyncStatus.synced;
      await _taskBox.put(task.key, task); // Use task.key for HiveObject
    } catch (e) {
      print('Error sending task ${task.id} to backend: $e');
      task.syncStatus = SyncStatus.failed; // Mark as failed to allow for retry
      await _taskBox.put(task.key, task);
      // Handle error: retry logic, user notification, etc.
    }
  }

  @override
  void dispose() {
    _hiveSubscription?.cancel();
    super.dispose();
  }
}

final taskSyncViewModelProvider = StateNotifierProvider<TaskSyncViewModel, void>((ref) {
  final taskBox = ref.watch(taskBoxProvider).asData?.value;
  final taskRepository = ref.watch(taskRepositoryProvider);
  if (taskBox != null) {
    return TaskSyncViewModel(taskBox, taskRepository);
  }
  throw Exception("TaskBox not available");
});
