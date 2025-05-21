import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trans_video_x/models/task_model.dart'; // Import your TaskModel
import 'package:intl/intl.dart'; // For date formatting

const String tasksBoxName = 'tasksBox'; // Hive box name, ensure it's the same as in home_screen.dart

@RoutePage()
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  late Box<TaskModel> _tasksBox;
  bool _isBoxOpen = false;

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    // Ensure Hive is initialized (usually in main.dart)
    // await Hive.initFlutter(); // If not already initialized
    // Hive.registerAdapter(TaskModelAdapter()); // If not already registered

    _tasksBox = await Hive.openBox<TaskModel>(tasksBoxName);
    if (mounted) {
      setState(() {
        _isBoxOpen = true;
      });
      // Listen to box changes to rebuild UI if needed
      _tasksBox.listenable().addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  Future<void> _deleteTask(String taskId) async {
    await _tasksBox.delete(taskId);
    // setState will be called by the listener
  }

  @override
  void dispose() {
    // It's good practice to close the box when the widget is disposed,
    // though Hive handles this fairly well.
    // _tasksBox.close(); // Consider if this is needed based on your app's lifecycle
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isBoxOpen) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('历史记录'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final tasks = _tasksBox.values.toList().cast<TaskModel>();
    // Sort tasks by uploadTime in descending order (newest first)
    tasks.sort((a, b) {
      try {
        return DateTime.parse(b.uploadTime).compareTo(DateTime.parse(a.uploadTime));
      } catch (e) {
        // Handle potential parsing errors, e.g., if uploadTime is not a valid ISO string
        return 0;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('历史记录'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: '删除所有记录',
            onPressed: tasks.isEmpty ? null : () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('确认删除'),
                    content: const Text('确定要删除所有历史记录吗？此操作无法撤销。'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('取消'),
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                      ),
                      TextButton(
                        child: const Text('删除', style: TextStyle(color: Colors.red)),
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                      ),
                    ],
                  );
                },
              );
              if (confirm == true) {
                await _tasksBox.clear();
                 if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('所有历史记录已删除。')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: tasks.isEmpty
          ? const Center(
              child: Text('没有历史记录。'),
            )
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                String formattedUploadTime = 'N/A';
                try {
                  DateTime uploadDateTime = DateTime.parse(task.uploadTime);
                  formattedUploadTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(uploadDateTime);
                } catch (e) {
                  // Log error or handle as needed
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
                              onPressed: () => _deleteTask(task.id),
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
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}