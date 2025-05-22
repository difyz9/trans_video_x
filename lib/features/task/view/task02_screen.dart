import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:trans_video_x/models/add_url_model.dart';
import 'package:trans_video_x/core/constants/app_constants.dart';
import 'package:trans_video_x/features/task/model/task_status.dart';
import 'package:trans_video_x/features/task/provider/task_provider.dart';
// import 'package:trans_video_x/core/widget/task_status_indicator.dart'; // Assuming TaskStatusOverview is not used here or defined elsewhere

// The original Task class is removed as we are now using AddUrlModel

@RoutePage()
class Task02Screen extends ConsumerStatefulWidget {
  const Task02Screen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _Task02ScreenState();
}

class _Task02ScreenState extends ConsumerState<Task02Screen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Box<AddUrlModel> _urlBox;
  bool _isLoading = true;

  // Audio and frames upload endpoints (consider moving to a config file)
  static const String audioUploadEndpoint = 'https://api.example.com/audio';
  static const String framesUploadEndpoint = 'https://api.example.com/frames';

  late TaskStatusNotifier _taskStatusNotifier;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // "全部", "处理中", "已完成", "失败"
    _taskStatusNotifier = ref.read(taskStatusProvider.notifier);
    _openBox();
  }

  Future<void> _openBox() async {
    try {
      _urlBox = await Hive.openBox<AddUrlModel>(AppConstants.addUrlModelBoxName);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
    if (_isLoading) return; // Don't process if box isn't open

    final taskNotifier = _taskStatusNotifier;
    ref.read(isPollingProvider.notifier).state = false; // Reset polling state initially

    if (_urlBox.isEmpty) {
      print('No URLs found in Task02Screen. Starting polling for new URLs...');
      ref.read(isPollingProvider.notifier).state = true;
      taskNotifier.startPolling(
        urlBox: _urlBox,
        audioUploadEndpoint: audioUploadEndpoint,
        framesUploadEndpoint: framesUploadEndpoint,
      );
    } else {
      print('Found ${_urlBox.length} URLs in Task02Screen. Starting processing...');
      taskNotifier.checkAndProcessPendingUrls(
        urlBox: _urlBox,
        audioUploadEndpoint: audioUploadEndpoint,
        framesUploadEndpoint: framesUploadEndpoint,
      );
    }
    if (mounted) {
      setState(() {}); // Refresh UI, especially tab counts
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _taskStatusNotifier.stopPolling();
    // _urlBox.close(); // Consider if box should be closed here or managed globally
    super.dispose();
  }

  List<AddUrlModel> _getFilteredTasks(String statusCategory) {
    if (_isLoading || !_urlBox.isOpen) return [];

    final allModels = _urlBox.values.toList().reversed.toList(); // Show newest first
    final taskStatuses = ref.watch(taskStatusProvider);

    if (statusCategory == '全部') {
      return allModels;
    }

    return allModels.where((model) {
      final statusState = model.id != null ? taskStatuses[model.id] : null;
      if (statusState == null) {
        // Treat as pending if no status yet, or decide how to categorize
        return statusCategory == '处理中'; // Example: put items without status in "处理中"
      }
      switch (statusCategory) {
        case '处理中':
          return statusState.status != TaskStatus.completed && statusState.status != TaskStatus.error;
        case '已完成':
          return statusState.status == TaskStatus.completed;
        case '失败':
          return statusState.status == TaskStatus.error;
        default:
          return false;
      }
    }).toList();
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Watch providers that affect tab counts or list content
    ref.watch(taskStatusProvider);
    ref.watch(isPollingProvider);


    return Scaffold(
      body: _buildBody001(),
    );
  }

  Widget _buildBody001() {
    final tabTitles = ['全部', '处理中', '已完成', '失败'];
    return Column(
      children: [
        // Padding(
        //   padding: const EdgeInsets.all(1.0),
        //   child: Row(
        //     children: [
        //       const Text("任务列表", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        //       Spacer(),
        //       Consumer(builder: (context, ref, _) { // Consumer for polling indicator
        //         final isPolling = ref.watch(isPollingProvider);
        //         if (isPolling) {
        //           return const Padding(
        //             padding: EdgeInsets.only(right: 8.0),
        //             child: SizedBox(
        //               width: 16,
        //               height: 16,
        //               child: CircularProgressIndicator(strokeWidth: 2),
        //             ),
        //           );
        //         }
        //         return const SizedBox.shrink();
        //       }),
        //       IconButton(
        //         onPressed: () {
        //           _startProcessingUrls();
        //         },
        //         icon: const Icon(Icons.refresh)
        //       ),
        //       // IconButton(onPressed: (){}, icon: const Icon(Icons.filter_list)), // Filter button, functionality TBD
        //     ],
        //   ),
        // ),
        TabBar(
          controller: _tabController,
          tabs: tabTitles.map((title) {
            final count = _getFilteredTasks(title).length;
            return Tab(text: '$title $count');
          }).toList(),
        ),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: _urlBox.listenable(),
            builder: (context, Box<AddUrlModel> box, _) {
              // Rebuild TabBarView children when box changes or task statuses change
              // The taskStatusProvider is watched in the main build method, triggering rebuilds
              return TabBarView(
                controller: _tabController,
                children: tabTitles.map((title) {
                  return _buildTaskList(_getFilteredTasks(title));
                }).toList(),
              );
            }
          ),
        ),
      ],
    );
  }

  Widget _buildTaskList(List<AddUrlModel> tasks) {
    if (tasks.isEmpty) {
      final isPolling = ref.watch(isPollingProvider);
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('没有任务'),
            if (isPolling && _urlBox.isEmpty) ...[ // Show polling message if box is empty and polling
               const SizedBox(height: 16),
               const SizedBox(width: 24, height: 24, child: CircularProgressIndicator()),
               const SizedBox(height: 8),
               const Text('正在等待新的URL数据...'),
            ] else if (!_urlBox.isOpen || _urlBox.isEmpty) ... [ // Offer to start polling if box is empty and not polling
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(isPollingProvider.notifier).state = true;
                   _taskStatusNotifier.startPolling(
                    urlBox: _urlBox,
                    audioUploadEndpoint: audioUploadEndpoint,
                    framesUploadEndpoint: framesUploadEndpoint,
                  );
                },
                child: const Text('开始轮询新任务'),
              ),
            ]
          ],
        )
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        // Find the original index in the box for deletion, as tasks list is filtered and reversed
        final urlVo = tasks[index];
        final originalBoxIndex = _urlBox.values.toList().indexWhere((item) => item.id == urlVo.id);
        return _buildTaskItem(urlVo, originalBoxIndex);
      },
    );
  }

  Widget _buildTaskItem(AddUrlModel urlVo, int originalBoxIndex) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    final formattedDate = dateFormat.format(urlVo.timestamp);
    final taskStatuses = ref.watch(taskStatusProvider);
    final taskStatusState = urlVo.id != null ? taskStatuses[urlVo.id] : null;

    Color statusColor = Colors.grey.shade100;
    String statusText = "未知";
    Color statusTextColor = Colors.grey.shade800;

    if (taskStatusState != null) {
      statusText = taskStatusState.status.name;
      switch (taskStatusState.status) {
        case TaskStatus.pending:
          statusColor = Colors.orange.shade100;
          statusTextColor = Colors.orange.shade800;
          break;
        case TaskStatus.downloading:
        case TaskStatus.extractingAudio:
        case TaskStatus.extractingFrames:
        case TaskStatus.uploadingAudio:
        case TaskStatus.uploadingFrames:
          statusColor = Colors.blue.shade100;
          statusTextColor = Colors.blue.shade800;
          break;
        case TaskStatus.completed:
          statusColor = Colors.green.shade100;
          statusTextColor = Colors.green.shade800;
          break;
        case TaskStatus.error:
          statusColor = Colors.red.shade100;
          statusTextColor = Colors.red.shade800;
          break;
      }
    } else {
        statusText = "等待处理"; // Default for items not yet in taskStatusProvider
        statusColor = Colors.grey.shade100;
        statusTextColor = Colors.grey.shade800;
    }


    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () => _showUrlDetails(urlVo),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      urlVo.title ?? urlVo.url ?? '无标题',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                          color: statusTextColor,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (urlVo.url != null)
                Text(urlVo.url!, style: TextStyle(color: Colors.grey.shade700), maxLines: 1, overflow: TextOverflow.ellipsis,),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text('添加时间: $formattedDate', style: TextStyle(color: Colors.grey.shade600)),
                  const Spacer(),
                   if (originalBoxIndex != -1) // Ensure item is found in box before showing delete
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red.shade300),
                      onPressed: () => _deleteUrlByModel(urlVo), // Use model for safer deletion
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    )
                ],
              ),
              if (taskStatusState != null && taskStatusState.message != null && taskStatusState.message!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(taskStatusState.status == TaskStatus.error ? Icons.error_outline : Icons.info_outline, size: 16, color: taskStatusState.status == TaskStatus.error ? Colors.red.shade600 : Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Expanded(child: Text('状态: ${taskStatusState.message}', style: TextStyle(color: taskStatusState.status == TaskStatus.error ? Colors.red.shade600 : Colors.grey.shade600, fontSize: 12))),
                  ],
                ),
              ],
              if (taskStatusState != null &&
                  taskStatusState.status != TaskStatus.completed &&
                  taskStatusState.status != TaskStatus.error)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: LinearProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper to build status badge, similar to TaskScreen
  Widget _buildStatusBadge(TaskStatus status) {
    // This is now integrated into _buildTaskItem's status display logic
    // but can be extracted if needed elsewhere.
    // For now, the logic in _buildTaskItem handles this.
    // If you need a standalone badge, you can adapt the logic from TaskScreen's _buildStatusBadge.
    // Example:
    Color color;
    String text = status.name;
    switch (status) {
      case TaskStatus.pending: color = Colors.grey; break;
      case TaskStatus.downloading: color = Colors.blue; break;
      case TaskStatus.extractingFrames: color = Colors.indigo; break;
      case TaskStatus.extractingAudio: color = Colors.purple; break;
      case TaskStatus.uploadingAudio: color = Colors.orange; break;
      case TaskStatus.uploadingFrames: color = Colors.deepOrange; break;
      case TaskStatus.completed: color = Colors.green; break;
      case TaskStatus.error: color = Colors.red; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }

  void _deleteUrlByModel(AddUrlModel urlVoToDelete) {
    // Find the item in the box by its unique ID to ensure correct deletion
    final boxKey = _urlBox.keys.firstWhere((key) {
      final item = _urlBox.get(key);
      return item?.id == urlVoToDelete.id;
    }, orElse: () => null);

    if (boxKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('错误：无法找到要删除的任务')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除任务 "${urlVoToDelete.title ?? urlVoToDelete.url}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              _urlBox.delete(boxKey);
              // Optionally, remove from taskStatusProvider if it holds state for deleted items
              if (urlVoToDelete.id != null) {
                ref.read(taskStatusProvider.notifier).removeStatus(urlVoToDelete.id!);
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('任务已删除')),
              );
              // setState to refresh counts, ValueListenableBuilder will handle list update
              if(mounted) setState(() {});
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
        return Consumer( // Use Consumer to get latest task status in dialog
          builder: (context, ref, child) {
            final taskStatuses = ref.watch(taskStatusProvider);
            final taskStatusState = urlVo.id != null ? taskStatuses[urlVo.id] : null;

            return AlertDialog(
              title: const Text('任务详情'),
              content: SingleChildScrollView( // Ensure content is scrollable
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDetailRow('ID', urlVo.id ?? 'N/A'),
                    _buildDetailRow('URL', urlVo.url ?? 'N/A'),
                    _buildDetailRow('标题', urlVo.title ?? 'N/A'),
                    _buildDetailRow('描述', urlVo.description ?? 'N/A'),
                    _buildDetailRow('播放列表ID', urlVo.playlistId ?? 'N/A'),
                    _buildDetailRow('操作类型', urlVo.operationType ?? 'N/A'),
                    _buildDetailRow('添加时间', DateFormat('yyyy-MM-dd HH:mm:ss').format(urlVo.timestamp)),
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),
                    if (taskStatusState != null) ...[
                      Row(
                        children: [
                          const Text('处理状态: ', style: TextStyle(fontWeight: FontWeight.bold)),
                          _buildStatusBadge(taskStatusState.status), // Use the helper here
                        ],
                      ),
                      if (taskStatusState.message != null && taskStatusState.message!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(taskStatusState.message!),
                        ),
                    ] else
                      const Text('未处理', style: TextStyle(fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
              actions: [
                if (urlVo.url != null &&
                    (taskStatusState == null || taskStatusState.status == TaskStatus.error || taskStatusState.status == TaskStatus.pending))
                  TextButton(
                    onPressed: () {
                      _taskStatusNotifier.processUrl(
                        urlVo,
                        audioUploadEndpoint: audioUploadEndpoint,
                        framesUploadEndpoint: framesUploadEndpoint,
                      );
                      Navigator.pop(dialogContext);
                       ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('开始处理 "${urlVo.title ?? urlVo.url}"')),
                      );
                    },
                    child: const Text('重新处理'),
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
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}