
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trans_video_x/models/add_url_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import 'package:trans_video_x/features/task/model/task_status.dart';
import 'package:trans_video_x/features/task/provider/task_provider.dart';
import 'package:trans_video_x/core/widget/task_status_indicator.dart';

@RoutePage()
class TaskScreen extends ConsumerStatefulWidget {
  const TaskScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TaskScreenState();
}

class _TaskScreenState extends ConsumerState<TaskScreen> {
 static const String urlVoBoxName = 'urlVos';
  late Box<AddUrlModel> _urlBox;
  bool _isLoading = true;
  // Audio and frames upload endpoints
  static const String audioUploadEndpoint = 'https://api.example.com/audio';
  static const String framesUploadEndpoint = 'https://api.example.com/frames';

  late TaskStatusNotifier _taskStatusNotifier;

  @override
  void initState() {
    super.initState();
    _taskStatusNotifier = ref.read(taskStatusProvider.notifier);
    _openBox();
  }

  Future<void> _openBox() async {
    try {
      _urlBox = await Hive.openBox<AddUrlModel>(urlVoBoxName);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // After box is opened, start processing URLs
        _startProcessingUrls();
      }
    } catch (e) {
      print('Error opening Hive box: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: ${e.toString()}')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  void _startProcessingUrls() {
    // Get the task provider
    final taskNotifier = _taskStatusNotifier;
    
    if (_urlBox.isEmpty) {
      // If there are no URLs, start polling the database
      print('No URLs found. Starting polling for new URLs...');
      ref.read(isPollingProvider.notifier).state = true;
      taskNotifier.startPolling(
        urlBox: _urlBox,
        audioUploadEndpoint: audioUploadEndpoint,
        framesUploadEndpoint: framesUploadEndpoint,
      );
    } else {
      // If there are URLs, start processing them
      print('Found ${_urlBox.length} URLs. Starting processing...');
      ref.read(isPollingProvider.notifier).state = false;
      taskNotifier.checkAndProcessPendingUrls(
        urlBox: _urlBox,
        audioUploadEndpoint: audioUploadEndpoint,
        framesUploadEndpoint: framesUploadEndpoint,
      );
    }
  }
  
  @override
  void dispose() {
    // Stop polling when screen is disposed
    _taskStatusNotifier.stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('URL列表')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('URL列表'),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final isPolling = ref.watch(isPollingProvider);
              
              return Row(
                children: [
                  if (isPolling)
                    const Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      // Refresh UI and start processing
                      _startProcessingUrls();
                      setState(() {});
                    },
                  ),
                ],
              );
            }
          ),
        ],
      ),
      body: Column(
        children: [
          // Task status overview
          const TaskStatusOverview(),
          
          // URL list
          Expanded(
            child: _buildUrlList(),
          ),
        ],
      ),
    );
  }

  Widget _buildUrlList() {
    return ValueListenableBuilder(
      valueListenable: _urlBox.listenable(),
      builder: (context, Box<AddUrlModel> box, _) {
        if (box.isEmpty) {
          // Show empty state with polling status
          return Consumer(
            builder: (context, ref, _) {
              final isPolling = ref.watch(isPollingProvider);
              
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('没有保存的URL数据'),
                    const SizedBox(height: 16),
                    if (isPolling) ...[
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(),
                      ),
                      const SizedBox(height: 8),
                      const Text('正在等待新的URL数据 (每5秒检查一次)'),
                    ] else
                      ElevatedButton(
                        onPressed: () {
                          ref.read(isPollingProvider.notifier).state = true;
                          ref.read(taskStatusProvider.notifier).startPolling(
                            urlBox: _urlBox,
                            audioUploadEndpoint: audioUploadEndpoint,
                            framesUploadEndpoint: framesUploadEndpoint,
                          );
                        },
                        child: const Text('开始轮询'),
                      ),
                  ],
                ),
              );
            }
          );
        }
        
        return ListView.builder(
          itemCount: box.length,
          itemBuilder: (context, index) {
            final urlVo = box.getAt(box.length - 1 - index); // 倒序显示，最新的显示在顶部
            if (urlVo == null) {
              return const SizedBox.shrink();
            }
            return _buildUrlCard(urlVo, box.length - 1 - index);
          },
        );
      },
    );
  }

  Widget _buildUrlCard(AddUrlModel urlVo, int index) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    final formattedDate = dateFormat.format(urlVo.timestamp);

    // Get task status from provider
    return Consumer(
      builder: (context, ref, child) {
        final taskStatuses = ref.watch(taskStatusProvider);
        
        // Find status for this URL if it exists
        final taskStatus = urlVo.id != null ? taskStatuses[urlVo.id] : null;
        
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              ListTile(
                title: Text(
                  urlVo.title ?? urlVo.url ?? '无URL',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      urlVo.url ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '添加时间: $formattedDate',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (taskStatus != null) ...[
                          const SizedBox(width: 8),
                          _buildStatusBadge(taskStatus.status),
                        ],
                      ],
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteUrl(index),
                ),
                onTap: () => _showUrlDetails(urlVo),
              ),
              
              // Show task status message if available
              if (taskStatus != null && taskStatus.message != null)
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          taskStatus.message!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
                
              // Show progress indicator for pending/in-progress tasks
              if (taskStatus != null && 
                  taskStatus.status != TaskStatus.completed && 
                  taskStatus.status != TaskStatus.error)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: LinearProgressIndicator(),
                ),
            ],
          ),
        );
      }
    );
  }
  
  Widget _buildStatusBadge(TaskStatus status) {
    Color color;
    String text;
    
    switch (status) {
      case TaskStatus.pending:
        color = Colors.grey;
        text = '等待中';
        break;
      case TaskStatus.downloading:
        color = Colors.blue;
        text = '下载中';
        break;
      case TaskStatus.extractingFrames:
        color = Colors.indigo;
        text = '提取帧';
        break;
      case TaskStatus.extractingAudio:
        color = Colors.purple;
        text = '提取音频';
        break;
      case TaskStatus.uploadingAudio:
        color = Colors.orange;
        text = '上传音频';
        break;
      case TaskStatus.uploadingFrames:
        color = Colors.deepOrange;
        text = '上传帧';
        break;
      case TaskStatus.completed:
        color = Colors.green;
        text = '已完成';
        break;
      case TaskStatus.error:
        color = Colors.red;
        text = '错误';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  void _deleteUrl(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个URL记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              _urlBox.deleteAt(index);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('URL已删除')),
              );
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showUrlDetails(AddUrlModel urlVo) {
    final BuildContext currentContext = context;
    
    showDialog(
      context: currentContext,
      builder: (dialogContext) {
        // Check task status
        return Consumer(
          builder: (context, ref, child) {
            final taskStatuses = ref.watch(taskStatusProvider);
            final taskStatus = urlVo.id != null ? taskStatuses[urlVo.id] : null;
            
            return AlertDialog(
              title: const Text('URL详情'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailRow('ID', urlVo.id ?? ''),
                  _buildDetailRow('URL', urlVo.url ?? ''),
                  _buildDetailRow('标题', urlVo.title ?? ''),
                  _buildDetailRow('描述', urlVo.description ?? ''),
                  _buildDetailRow('播放列表ID', urlVo.playlistId ?? ''),
                  _buildDetailRow('操作类型', urlVo.operationType ?? ''),
                  _buildDetailRow('时间戳', DateFormat('yyyy-MM-dd HH:mm:ss').format(urlVo.timestamp)),
                  
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  
                  if (taskStatus != null) ...[
                    Row(
                      children: [
                        const Text('处理状态: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        _buildStatusBadge(taskStatus.status),
                      ],
                    ),
                    if (taskStatus.message != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(taskStatus.message!),
                      ),
                  ] else
                    const Text('未处理', style: TextStyle(fontStyle: FontStyle.italic)),
                ],
              ),
              actions: [
                // Add action to manually process this URL if it's not already being processed
                if (urlVo.url != null && 
                    (taskStatus == null || 
                     taskStatus.status == TaskStatus.error))
                  TextButton(
                    onPressed: () {
                      ref.read(taskStatusProvider.notifier).processUrl(
                        urlVo,
                        audioUploadEndpoint: audioUploadEndpoint,
                        framesUploadEndpoint: framesUploadEndpoint,
                      );
                      Navigator.pop(dialogContext);
                    },
                    child: const Text('处理此URL'),
                  ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('关闭'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
