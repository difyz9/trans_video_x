import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:trans_video_x/core/widget/file_drop_screen.dart';
import 'package:intl/intl.dart'; // Added for DateFormat

@RoutePage()
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedSourceLanguage = '中文';
  String _selectedTargetLanguage = 'English';

  // Unified list for all tasks, including initial ones and newly added ones.
  List<Map<String, dynamic>> _allTasks = [
    // Initial placeholder tasks
    {
      "name": "产品演示视频.mp4",
      "time": "2024-01-18 14:30",
      "source": "中文",
      "target": "英语",
      "status": "已完成",
      "path": null, // Ensure all task items have consistent keys
      "formattedSize": "N/A",
      "type": "mp4",
    },
    {
      "name": "会议记录.mp4",
      "time": "2024-01-18 10:15",
      "source": "中文",
      "target": "日语",
      "status": "处理中",
      "path": null, // Ensure all task items have consistent keys
      "formattedSize": "N/A",
      "type": "mp4",
    },
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
      };
    }).toList();

    setState(() {
      _allTasks.insertAll(0, newTasks); // Add new tasks to the top of the list
    });
  }

  void _resetSelectionsAndPendingTasks() {
    setState(() {
      // Remove tasks that are "待处理"
      _allTasks.removeWhere((task) => task['status'] == '待处理');
      // Reset language selections
      _selectedSourceLanguage = '中文';
      _selectedTargetLanguage = 'English';
      // Potentially clear other states if needed
    });
  }

  void _startAllPendingTasks() {
    bool hasPendingTasks = _allTasks.any((task) => task['status'] == '待处理');
    if (!hasPendingTasks) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('没有待处理的任务。')),
      );
      return;
    }
    setState(() {
      for (var task in _allTasks) {
        if (task['status'] == '待处理') {
          task['status'] = '处理中';
          // TODO: Add actual task start logic here
          print('Starting task: ${task['name']}');
        }
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('所有待处理任务已开始。')),
    );
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
                // Action Buttons Row
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
            // End of Action Buttons Row
              ],
            ),
            const SizedBox(height: 8),
            const Text('上传视频文件开始翻译', style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 24),

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
                      isDense: true, // Makes the field more compact
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12), // Adjust padding
                    ),
                    value: _selectedSourceLanguage, // Use state variable
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
                      isDense: true, // Makes the field more compact
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12), // Adjusted horizontal padding
                    ),
                    value: _selectedTargetLanguage, // Use state variable
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

            const SizedBox(height: 24),
            FileDropWidget(
              onFilesSelected: _handleFilesSelected,
              initialFiles: const [], // Pass empty list to clear FileDropWidget after selection
            ),
            
            // const SizedBox(height: 24),

           

            const SizedBox(height: 32),

            // Recent Tasks Section
        
            Row(
              children: [
                    const Text(
              '任务列表',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {},
                  tooltip: 'Settings',),
              ],
            ),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: DataTable(
                columnSpacing: 24, // Increased column spacing
                dataRowMinHeight: 52, // Added min height for data rows
                dataRowMaxHeight: 64, // Added max height for data rows
                headingRowHeight: 56, // Increased heading row height
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
                          label: Text(task['status']! as String),
                          backgroundColor: task['status'] == '已完成' 
                              ? Colors.green.shade100 
                              : task['status'] == '处理中' 
                                  ? Colors.orange.shade100 
                                  : task['status'] == '待处理'
                                      ? Colors.blue.shade100
                                      : Colors.grey.shade100, // Default color
                          labelStyle: TextStyle(
                            color: task['status'] == '已完成' 
                                ? Colors.green.shade800 
                                : task['status'] == '处理中' 
                                    ? Colors.orange.shade800
                                    : task['status'] == '待处理'
                                        ? Colors.blue.shade800
                                        : Colors.black, // Default color
                            fontWeight: FontWeight.bold
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        ),
                      ),
                    ),
                    DataCell(
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: task['status'] == '待处理'
                          ? ElevatedButton(
                              child: const Text('开始任务'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                textStyle: const TextStyle(fontSize: 12)
                              ),
                              onPressed: () {
                                // TODO: Implement start task logic
                                print('Start task for: ${task['name']} at path ${task['path']}');
                                setState(() {
                                  task['status'] = '处理中'; 
                                });
                              },
                            )
                          : Row( 
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (task['status'] == '已完成')
                                  IconButton(icon: const Icon(Icons.download_outlined, color: Colors.blue), onPressed: () {
                                    print('Download: ${task['name']}');
                                    // TODO: Implement download
                                  }),
                                IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () {
                                  print('Delete: ${task['name']}');
                                  setState(() {
                                    _allTasks.remove(task);
                                  });
                                  // TODO: Implement delete
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