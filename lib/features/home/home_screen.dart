import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Placeholder data for recent tasks
    final List<Map<String, String>> recentTasks = [
      {
        "name": "产品演示视频.mp4",
        "time": "2024-01-18 14:30",
        "source": "中文",
        "target": "英语",
        "status": "已完成"
      },
      {
        "name": "会议记录.mp4",
        "time": "2024-01-18 10:15",
        "source": "中文",
        "target": "日语",
        "status": "处理中"
      },
    ];

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
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('新建翻译任务'),
                  onPressed: () {
                    // TODO: Implement new task action
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
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
                    value: '中文', // Default value
                    items: ['中文', 'English']
                        .map((label) => DropdownMenuItem(
                              value: label,
                              child: Text(label),
                            ))
                        .toList(),
                    onChanged: (value) {
                      // TODO: Handle source language change
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
                    value: 'English', // Default value
                    items: ['English', '日语', '中文']
                        .map((label) => DropdownMenuItem(
                              value: label,
                              child: Text(label),
                            ))
                        .toList(),
                    onChanged: (value) {
                      // TODO: Handle target language change
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

            // File Upload Area
            Container(
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid, width: 2),
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.grey.shade50,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.upload_file, size: 48, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      '拖拽视频文件到这里, 或',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      child: const Text('选择文件'),
                      onPressed: () {
                        // TODO: Implement file selection
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '支持 MP4、AVI、MOV 等格式, 最大 500MB',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Recent Tasks Section
            const Text(
              '最近任务',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: DataTable(
                columnSpacing: 16,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
                columns: const [
                  DataColumn(label: Text('文件名', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('上传时间', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('源语言', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('目标语言', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('状态', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('操作', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: recentTasks.map((task) {
                  return DataRow(cells: [
                    DataCell(Text(task['name']!)),
                    DataCell(Text(task['time']!)),
                    DataCell(Text(task['source']!)),
                    DataCell(Text(task['target']!)),
                    DataCell(
                      Chip(
                        label: Text(task['status']!),
                        backgroundColor: task['status'] == '已完成' ? Colors.green.shade100 : Colors.orange.shade100,
                        labelStyle: TextStyle(
                          color: task['status'] == '已完成' ? Colors.green.shade800 : Colors.orange.shade800,
                          fontWeight: FontWeight.bold
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      )
                    ),
                    DataCell(Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.download_outlined, color: Colors.blue), onPressed: () {
                           // TODO: Implement download
                        }),
                        IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () {
                           // TODO: Implement delete
                        }),
                      ],
                    )),
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