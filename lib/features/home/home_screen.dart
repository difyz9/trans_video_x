import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:trans_video_x/core/cos/providers/cos_providers.dart';
import 'package:trans_video_x/core/utils/file_utils.dart';
import 'package:trans_video_x/core/widget/file_drop_screen.dart';
import 'package:intl/intl.dart';
import 'package:trans_video_x/models/task_model.dart'; // Keep TaskModel for structure
import 'package:trans_video_x/routes/app_route.gr.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http; // Added for HTTP requests
import 'dart:convert'; // Added for jsonEncode

// TODO: Configure your API base URL
const String apiBaseUrl = 'http://127.0.0.1:55001/api'; // Example: 'http://localhost:5001/api' or your server IP

@RoutePage()
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedSourceLanguage = 'English';
  String _selectedTargetLanguage = '中文';

  // Unified list for all tasks, including initial ones and newly added ones.
  List<Map<String, dynamic>> _allTasks = [];
  final Uuid _uuid = Uuid(); // UUID generator

  @override
  void initState() {
    super.initState();
    // Initialize _allTasks if needed from persistence or other sources in the future
    // If you want to load tasks from the API on init, you can do it here.
  }

  void _handleFilesSelected(List<Map<String, dynamic>> selectedFilesData) {
    final newTasks = selectedFilesData.map((fileData) {
      return {
        'id': _uuid.v4(), // Generate ID upfront for API consistency
        'name': fileData['name'] as String,
        'path': fileData['path'] as String,
        'size': fileData['size'] as int, // From FileDropWidget
        'formattedSize': fileData['formattedSize'] as String, // From FileDropWidget
        'type': fileData['type'] as String, // From FileDropWidget
        'time': DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()), // UI display time
        'uploadTime': DateTime.now().toIso8601String(), // For API
        'source': _selectedSourceLanguage,
        'target': _selectedTargetLanguage,
        'status': '待处理', // New status for pending tasks
        'error': null, // For storing error messages
        'cosObjectKey': null, // Will be set after upload
      };
    }).toList();

    setState(() {
      _allTasks.insertAll(0, newTasks); // Add new tasks to the top of the list
    });
  }

  Future<void> _startSingleTask(Map<String, dynamic> task) async {
    final cosNotifier = ref.read(cosOperationProvider.notifier);
    final String? localFilePath = task['path'] as String?;
    final String originalFileName = task['name'] as String;

    if (localFilePath == null || localFilePath.isEmpty) {
      print('File path is missing for task: $originalFileName');
      if (mounted) {
        setState(() {
          task['status'] = '上传失败';
          task['error'] = '文件路径缺失';
        });
      }
      return;
    }

    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String? fileHash = await FileUtils.instance.getFileHashKey(localFilePath);
    final String fileName = fileHash?.substring(0, 10) ?? timestamp;
    final String fileExtension = originalFileName.contains('.') ? originalFileName.substring(originalFileName.lastIndexOf('.')) : '';
    final String cosObjectKey = 'uploads/$fileName/$fileName$fileExtension';

    try {
      if (mounted) {
        setState(() {
          task['status'] = '上传中...';
          task['error'] = null;
        });
      }

      await cosNotifier.uploadFile(filePath: localFilePath, objectKey: cosObjectKey);
      print('Successfully uploaded $originalFileName as $cosObjectKey.');
      task['cosObjectKey'] = cosObjectKey; // Update cosObjectKey in the local task map

      // Data to be sent to the API
      final apiTaskData = TaskModel(
        id: task['id'] as String, // Use the pre-generated ID
        cosObjectKey: cosObjectKey,
        name: task['name'] as String,
        path: task['path'] as String? ?? '',
        size: task['size'] as int,
        formattedSize: task['formattedSize'] as String,
        type: task['type'] as String,
        uploadTime: task['uploadTime'] as String, // Already in ISO8601String
        sourceLanguage: task['source'] as String,
        targetLanguage: task['target'] as String,
        status: '已上传待处理', // Status after successful upload
        // errorMessage will be null initially
      );

      // Send data to Flask API
      try {
        final response = await http.post(
          Uri.parse('$apiBaseUrl/save_task'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(apiTaskData.toJson()), // Assuming TaskModel has toJson()
        );

        if (response.statusCode == 201) {
          print('Task $originalFileName data successfully sent to API.');
          if (mounted) {
            setState(() {
              task['status'] = '处理中'; // API confirmed, backend processing starts
            });
          }
        } else {
          print('Failed to send task $originalFileName to API: ${response.statusCode} ${response.body}');
          if (mounted) {
            setState(() {
              task['status'] = 'API同步失败';
              task['error'] = 'API Error: ${response.statusCode}';
            });
          }
        }
      } catch (e) {
        print('Error sending task $originalFileName to API: $e');
        if (mounted) {
          setState(() {
            task['status'] = 'API连接失败';
            task['error'] = e.toString();
          });
        }
      }

    } catch (e) {
      print('Failed to upload task $originalFileName: $e');
      if (mounted) {
        setState(() {
          task['status'] = '上传失败';
          task['error'] = e.toString();
        });
      }
    }
  }

  void _resetSelectionsAndPendingTasks() {
    setState(() {
      // Remove tasks that are "待处理"
      _allTasks.removeWhere((task) => task['status'] == '待处理');
      // Reset language selections
      _selectedSourceLanguage = 'English';
      _selectedTargetLanguage = '中文';
      // Potentially clear other states if needed
    });
  }

  Future<void> _startAllPendingTasks() async {
    List<Map<String, dynamic>> tasksToProcess = _allTasks.where((task) => task['status'] == '待处理').toList();

    if (tasksToProcess.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('没有待处理的任务。')),
        );
      }
      return;
    }

    int startedCount = 0;
    for (var task in tasksToProcess) {
      await _startSingleTask(task); // Await each task's start, including upload
      if (task['status'] == '处理中' || task['status'] == '上传中...') {
        startedCount++;
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$startedCount 个任务已开始处理/上传。请查看列表了解具体状态。')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Title and New Task Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '视频翻译',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('重置'),
                        onPressed: _resetSelectionsAndPendingTasks,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('开始所有待处理任务'),
                        onPressed: _startAllPendingTasks,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Language Selection Row
            Row(
              children: [
                Container(
                  width: 200,
                  height: 40,
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: '源语言',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    ),
                    value: _selectedSourceLanguage,
                    items: ['中文', 'English']
                        .map((label) => DropdownMenuItem(
                              value: label,
                              child: Text(label),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedSourceLanguage = value;
                        });
                      }
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(Icons.arrow_forward),
                ),
                Container(
                  height: 40,
                  width: 200,
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: '目标语言',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    ),
                    value: _selectedTargetLanguage,
                    items: ['English', '日语', '中文']
                        .map((label) => DropdownMenuItem(
                              value: label,
                              child: Text(label),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedTargetLanguage = value;
                        });
                      }
                    },
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    // TODO: Implement settings action
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),
            FileDropWidget(
              onFilesSelected: _handleFilesSelected,
              initialFiles: const [],
            ),

            const SizedBox(height: 16),

            // Recent Tasks Section
            Row(
              children: [
                const Text(
                  '任务列表',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    AutoRouter.of(context).push(const HistoryRoute());
                  },
                  child: const Text("历史记录"),
                )
              ],
            ),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: DataTable(
                columnSpacing: 24,
                dataRowMinHeight: 52,
                dataRowMaxHeight: 64,
                headingRowHeight: 56,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
                columns: const [
                  DataColumn(label: Padding(padding: EdgeInsets.symmetric(horizontal: 8.0), child: Text('文件名', style: TextStyle(fontWeight: FontWeight.bold)))),
                  DataColumn(label: Padding(padding: EdgeInsets.symmetric(horizontal: 8.0), child: Text('上传时间', style: TextStyle(fontWeight: FontWeight.bold)))),
                  DataColumn(label: Padding(padding: EdgeInsets.symmetric(horizontal: 8.0), child: Text('源语言', style: TextStyle(fontWeight: FontWeight.bold)))),
                  DataColumn(label: Padding(padding: EdgeInsets.symmetric(horizontal: 8.0), child: Text('目标语言', style: TextStyle(fontWeight: FontWeight.bold)))),
                  DataColumn(label: Padding(padding: EdgeInsets.symmetric(horizontal: 8.0), child: Text('状态', style: TextStyle(fontWeight: FontWeight.bold)))),
                  DataColumn(label: Padding(padding: EdgeInsets.symmetric(horizontal: 8.0), child: Text('操作', style: TextStyle(fontWeight: FontWeight.bold)))),
                ],
                rows: _allTasks.map((task) {
                  return DataRow(cells: [
                    DataCell(Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), child: Text(task['name']! as String))),
                    DataCell(Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), child: Text(task['time']! as String))),
                    DataCell(Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), child: Text(task['source']! as String))),
                    DataCell(Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), child: Text(task['target']! as String))),
                    DataCell(
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: Chip(
                          label: Text(task['status']! as String), // Display status
                          backgroundColor: task['error'] != null
                              ? Colors.red[100]
                              : (task['status'] == '处理中' || task['status'] == '上传中...' ? Colors.blue[100] : Colors.green[100]),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        ),
                      ),
                    ),
                    DataCell(
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: task['status'] == '待处理'
                            ? ElevatedButton(
                                child: const Text('开始'),
                                onPressed: () => _startSingleTask(task),
                              )
                            : (task['error'] != null
                                ? Tooltip(message: task['error'] as String, child: Icon(Icons.error, color: Colors.red))
                                : (task['status'] == '上传中...' || task['status'] == '处理中'
                                    ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                                    : Icon(Icons.check_circle, color: Colors.green))),
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}