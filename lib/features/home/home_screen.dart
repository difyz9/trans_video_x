import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:trans_video_x/core/cos/providers/cos_providers.dart';
import 'package:trans_video_x/core/utils/file_utils.dart';
import 'package:trans_video_x/core/widget/file_drop_screen.dart';
import 'package:intl/intl.dart'; // Added for DateFormat
import 'package:hive_flutter/hive_flutter.dart'; // For Hive
import 'package:trans_video_x/models/task_model.dart';
import 'package:trans_video_x/routes/app_route.gr.dart';
import 'package:uuid/uuid.dart'; // Adjust the path as needed

const String tasksBoxName = 'tasksBox'; // Hive box name

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
  List<Map<String, dynamic>> _allTasks = [
 
  ];

  @override
  void initState() {
    super.initState();
    // Initialize _allTasks if needed from persistence or other sources in the future
  }

  void _handleFilesSelected(List<Map<String, dynamic>> selectedFilesData) {
    final newTasks = selectedFilesData.map((fileData) {
      return {
        'name': fileData['name'] as String,
        'path': fileData['path'] as String,
        'size': fileData['size'] as int, // From FileDropWidget
        'formattedSize': fileData['formattedSize'] as String, // From FileDropWidget
        'type': fileData['type'] as String, // From FileDropWidget
        'time': DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
        'source': _selectedSourceLanguage,
        'target': _selectedTargetLanguage,
        'status': '待处理', // New status for pending tasks
        'error': null, // For storing error messages
      };
    }).toList();

    setState(() {
      _allTasks.insertAll(0, newTasks); // Add new tasks to the top of the list
    });
  }

  Future<void> _startSingleTask(Map<String, dynamic> task) async {
    final cosNotifier = ref.read(cosOperationProvider.notifier); // Get the COS notifier
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

    // Generate a timestamp-based key for COS
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String? fileHash = await FileUtils.instance.getFileHashKey(localFilePath); // Await the hash

    final String fileName = fileHash?.substring(0, 10) ?? timestamp;

    final String fileExtension = originalFileName.contains('.') ? originalFileName.substring(originalFileName.lastIndexOf('.')) : '';
    final String cosObjectKey = 'uploads/$fileName/$fileName$fileExtension'; // Example: uploads/1678886400000.mp4



    try {
      if (mounted) {
        setState(() {
          task['status'] = '上传中...';
          task['error'] = null; // Clear previous error
        });
      }

      // Corrected: Use objectKey for the COS path
      await cosNotifier.uploadFile(filePath: localFilePath, objectKey: cosObjectKey);
      print('Successfully uploaded $originalFileName as $cosObjectKey.');

      // Store in Hive after successful upload
      try {
        final box = await Hive.openBox<TaskModel>(tasksBoxName);
        final taskToStore = TaskModel(
          id: Uuid().v4(), // Use a new UUID as a unique ID
          cosObjectKey: cosObjectKey,
          name: task['name'] as String,
          path: task['path'] as String? ?? '',
          size: task['size'] as int,
          formattedSize: task['formattedSize'] as String,
          type: task['type'] as String,
          uploadTime: DateTime.now().toIso8601String(),
          sourceLanguage: task['source'] as String,
          targetLanguage: task['target'] as String,
          status: '已上传待处理', // Status indicating successful upload, awaiting backend
        );
        await box.put(taskToStore.id, taskToStore);
        print('Task $originalFileName data stored in Hive with key: ${taskToStore.id}');
      } catch (hiveError) {
        print('Failed to store task $originalFileName in Hive: $hiveError');
      }

      if (mounted) {
        setState(() {
          task['status'] = '处理中'; // Indicates upload success, ready for backend
          task['cosObjectKey'] = cosObjectKey; // Store cosObjectKey in the UI task map
        });
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
            // const Text('上传视频文件开始翻译', style: TextStyle(fontSize: 14, color: Colors.grey)),
            // const SizedBox(height: 24),

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
                TextButton(onPressed: (){
                  AutoRouter.of(context).push(const HistoryRoute());
                }, child: const Text("历史记录"))
               
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
                  final String currentTaskCosKey = task['cosObjectKey'] as String? ?? (task['name']! as String);

                  return DataRow(cells: [
                    DataCell(Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), child: Text(task['name']! as String))),
                    DataCell(Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), child: Text(task['time']! as String))),
                    DataCell(Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), child: Text(task['source']! as String))),
                    DataCell(Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), child: Text(task['target']! as String))),
                    DataCell(
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: Chip(
                          label: Text(task['status']! as String),
                          backgroundColor: task['status'] == '已完成'
                              ? Colors.green.shade100
                              : task['status'] == '处理中'
                                  ? Colors.orange.shade100
                                  : task['status'] == '待处理'
                                      ? Colors.blue.shade100
                                      : task['status'] == '上传中...'
                                          ? Colors.purple.shade100
                                          : task['status'] == '上传失败'
                                              ? Colors.red.shade100
                                              : Colors.grey.shade100,
                          labelStyle: TextStyle(
                            color: task['status'] == '已完成'
                                ? Colors.green.shade800
                                : task['status'] == '处理中'
                                    ? Colors.orange.shade800
                                    : task['status'] == '待处理'
                                        ? Colors.blue.shade800
                                        : task['status'] == '上传中...'
                                            ? Colors.purple.shade800
                                            : task['status'] == '上传失败'
                                                ? Colors.red.shade800
                                                : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        ),
                      ),
                    ),
                    DataCell(
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: task['status'] == '待处理' || task['status'] == '上传失败'
                            ? ElevatedButton.icon(
                                icon: Icon(task['status'] == '上传失败' ? Icons.refresh : Icons.play_arrow),
                                label: Text(task['status'] == '上传失败' ? '重试' : '开始任务'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: task['status'] == '上传失败' ? Colors.orange : Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  textStyle: const TextStyle(fontSize: 12),
                                ),
                                onPressed: () => _startSingleTask(task),
                              )
                            : (task['status'] == '上传中...')
                                ? const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)),
                                      SizedBox(width: 8),
                                      Text("上传中...", style: TextStyle(fontSize: 12)),
                                    ],
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (task['status'] == '已完成')
                                        IconButton(
                                            icon: const Icon(Icons.download_outlined, color: Colors.blue),
                                            onPressed: () {
                                              print('Download: ${task['name']}');
                                            }),
                                      IconButton(
                                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                                          onPressed: () async {
                                            print('Delete: ${task['name']}');
                                            if (task['cosObjectKey'] != null) {
                                              try {
                                                final box = await Hive.openBox<TaskModel>(tasksBoxName);
                                                await box.delete(task['cosObjectKey']);
                                                print('Task ${task['name']} removed from Hive.');
                                              } catch (hiveError) {
                                                print('Failed to remove task ${task['name']} from Hive: $hiveError');
                                              }
                                            }
                                            setState(() {
                                              _allTasks.remove(task);
                                            });
                                          }),
                                    ],
                                  ),
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