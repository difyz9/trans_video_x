import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trans_video_x/models/task_model.dart'; // Import your TaskModel
import 'package:intl/intl.dart'; // For date formatting
import 'package:http/http.dart' as http; // Added for HTTP requests
import 'dart:convert'; // Added for jsonDecode

// TODO: Configure your API base URL (should be same as in home_screen.dart)
const String apiBaseUrl = 'http://127.0.0.1:55001/api';

final tasksProvider = FutureProvider<List<TaskModel>>((ref) async {
  final response = await http.get(Uri.parse('$apiBaseUrl/tasks'));
  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    return data.map((taskJson) => TaskModel.fromJson(taskJson)).toList();
  } else {
    throw Exception('Failed to load tasks from API: ${response.statusCode}');
  }
});

@RoutePage()
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _deleteTask(String taskId, BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: const Text('确定要删除此历史记录吗？此操作无法撤销。'),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
            ),
            TextButton(
              child: const Text('删除', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        final response = await http.delete(Uri.parse('$apiBaseUrl/task/$taskId'));
        if (response.statusCode == 200) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('任务已删除。')),
            );
            ref.refresh(tasksProvider); // Refresh the list after deletion
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('删除失败: ${response.statusCode}')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('删除出错: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteAllTasks(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('确认删除所有记录'),
          content: const Text('确定要删除所有历史记录吗？此操作无法撤销。'),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            TextButton(
              child: const Text('全部删除', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final tasksValue = ref.read(tasksProvider);
      tasksValue.whenData((tasks) async {
        bool allSucceeded = true;
        int successCount = 0;
        for (var task in tasks) {
          try {
            final response = await http.delete(Uri.parse('$apiBaseUrl/task/${task.id}'));
            if (response.statusCode == 200) {
              successCount++;
            } else {
              allSucceeded = false;
              print("Failed to delete task ${task.id}: ${response.statusCode}");
            }
          } catch (e) {
            allSucceeded = false;
            print("Error deleting task ${task.id}: $e");
          }
        }
        if (mounted) {
          if (allSucceeded && tasks.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('所有历史记录已删除。')),
            );
          } else if (successCount > 0 && !allSucceeded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$successCount 个记录已删除，部分失败。')),
            );
          } else if (tasks.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('没有记录可删除。')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('删除所有记录失败。')),
            );
          }
          ref.refresh(tasksProvider); // Refresh the list
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncTasks = ref.watch(tasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('历史记录'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '刷新列表',
            onPressed: () => ref.refresh(tasksProvider),
          ),
          asyncTasks.when(
            data: (tasks) => IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: '删除所有记录',
              onPressed: tasks.isEmpty ? null : () => _deleteAllTasks(context),
            ),
            loading: () => const IconButton(icon: Icon(Icons.delete_sweep), onPressed: null),
            error: (_, __) => const IconButton(icon: Icon(Icons.delete_sweep), onPressed: null),
          ),
        ],
      ),
      body: asyncTasks.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return const Center(
              child: Text('没有历史记录。'),
            );
          }
          tasks.sort((a, b) {
            try {
              final dateA = DateTime.tryParse(a.uploadTime);
              final dateB = DateTime.tryParse(b.uploadTime);
              if (dateA != null && dateB != null) {
                return dateB.compareTo(dateA);
              }
              return 0;
            } catch (e) {
              return 0;
            }
          });

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              String formattedUploadTime = 'N/A';
              try {
                DateTime? uploadDateTime = DateTime.tryParse(task.uploadTime);
                if (uploadDateTime != null) {
                  formattedUploadTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(uploadDateTime);
                }
              } catch (e) {
                print("Error parsing date: ${task.uploadTime}");
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              task.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            tooltip: '删除此记录',
                            onPressed: () => _deleteTask(task.id, context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('文件路径: ${task.path.isNotEmpty ? task.path : 'N/A'}'),
                      Text('文件大小: ${task.formattedSize}'),
                      Text('上传时间: $formattedUploadTime'),
                      Text('源语言: ${task.sourceLanguage}'),
                      Text('目标语言: ${task.targetLanguage}'),
                      Text('状态: ${task.status}'),
                      if (task.cosObjectKey.isNotEmpty) Text('COS Key: ${task.cosObjectKey}'),
                      if (task.errorMessage != null && task.errorMessage!.isNotEmpty) 
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text('错误: ${task.errorMessage}', style: TextStyle(color: Colors.red.shade700)),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('加载历史记录失败: $err'),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => ref.refresh(tasksProvider),
                child: const Text('重试'),
              )
            ],
          ),
        ),
      ),
    );
  }
}