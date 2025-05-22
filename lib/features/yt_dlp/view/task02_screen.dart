import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:trans_video_x/models/add_url_model.dart';
import 'package:trans_video_x/features/task/model/task_status.dart';
import 'package:trans_video_x/features/task/provider/task_provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const String ytDlpApiBaseUrl = 'http://127.0.0.1:55001/api';

@RoutePage()
class Task02Screen extends ConsumerStatefulWidget {
  const Task02Screen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _Task02ScreenState();
}

class _Task02ScreenState extends ConsumerState<Task02Screen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<AddUrlModel> _allUrlTasks = [];
  bool _isFetchingTasks = true;

  static const String audioUploadEndpoint = 'https://api.example.com/audio';
  static const String framesUploadEndpoint = 'https://api.example.com/frames';

  late TaskStatusNotifier _taskStatusNotifier;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _taskStatusNotifier = ref.read(taskStatusProvider.notifier);
    _fetchTasksAndInitiateProcessing();
  }

  Future<void> _fetchTasksAndInitiateProcessing() async {
    if (!mounted) return;
    setState(() {
      _isFetchingTasks = true;
    });

    try {
      final response = await http.get(Uri.parse('$ytDlpApiBaseUrl/url_tasks'));
      if (response.statusCode == 200) {
        final List<dynamic> taskData = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _allUrlTasks = taskData.map((data) => AddUrlModel.fromJson(data)).toList();
            _isFetchingTasks = false;
          });
          _initiateProcessingOfFetchedTasks();
        }
      } else {
        throw Exception('Failed to load URL tasks: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching URL tasks: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading tasks: ${e.toString()}')),
        );
        setState(() {
          _isFetchingTasks = false;
        });
      }
    }
  }

  void _initiateProcessingOfFetchedTasks() {
    if (_isFetchingTasks || !mounted) return;

    final taskNotifier = _taskStatusNotifier;
    bool currentlyPolling = ref.read(isPollingProvider);

    if (_allUrlTasks.isEmpty) {
      print('No URLs found from API. Starting API polling for new URLs...');
      if (!currentlyPolling) {
        ref.read(isPollingProvider.notifier).state = true;
      }
    } else {
      print('Found ${_allUrlTasks.length} URLs from API. Checking for pending tasks...');
      for (var task in _allUrlTasks) {
        final statusState = ref.read(taskStatusProvider)[task.id];
        if (statusState == null || statusState.status == TaskStatus.pending || statusState.status == TaskStatus.error) {
          print("Initiating processing for task: ${task.title ?? task.id}");
          taskNotifier.processUrl(
            task,
            audioUploadEndpoint: audioUploadEndpoint,
            framesUploadEndpoint: framesUploadEndpoint,
          );
        }
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<AddUrlModel> _getFilteredTasks(String statusCategory) {
    if (_isFetchingTasks) return [];

    final allModels = List<AddUrlModel>.from(_allUrlTasks).reversed.toList();
    final taskStatuses = ref.watch(taskStatusProvider);

    if (statusCategory == '全部') {
      return allModels;
    }

    return allModels.where((model) {
      final statusState = model.id != null ? taskStatuses[model.id] : null;
      if (statusState == null) {
        return statusCategory == '处理中';
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
    if (_isFetchingTasks) {
      return Scaffold(
        appBar: AppBar(title: const Text("URL任务处理")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    ref.watch(taskStatusProvider);
    ref.watch(isPollingProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("URL任务处理")),
      body: _buildBody001(),
    );
  }

  Widget _buildBody001() {
    final tabTitles = ['全部', '处理中', '已完成', '失败'];
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: tabTitles.map((title) {
            final count = _getFilteredTasks(title).length;
            return Tab(text: '$title $count');
          }).toList(),
        ),
        Expanded(
          child: Stack(
            children: [
              TabBarView(
                controller: _tabController,
                children: tabTitles.map((title) {
                  return _buildTaskList(_getFilteredTasks(title));
                }).toList(),
              ),
              Positioned(
                top: 8.0,
                right: 8.0,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        _fetchTasksAndInitiateProcessing();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Filter button pressed')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
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
            if (isPolling && _allUrlTasks.isEmpty) ...[
              const SizedBox(height: 16),
              const SizedBox(width: 24, height: 24, child: CircularProgressIndicator()),
              const SizedBox(height: 8),
              const Text('正在等待新的URL数据 (API)...'),
            ] else if (_allUrlTasks.isEmpty) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _fetchTasksAndInitiateProcessing();
                },
                child: const Text('刷新任务列表'),
              ),
            ]
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final urlVo = tasks[index];
        return _buildTaskItem(urlVo);
      },
    );
  }

  Widget _buildTaskItem(AddUrlModel urlVo) {
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
      statusText = "等待处理";
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
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red.shade300),
                    onPressed: () => _deleteUrlByModel(urlVo),
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

  void _deleteUrlByModel(AddUrlModel urlVoToDelete) {
    if (urlVoToDelete.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('错误：任务ID缺失，无法删除')),
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
            onPressed: () async {
              Navigator.pop(context);
              try {
                final response = await http.delete(
                  Uri.parse('$ytDlpApiBaseUrl/url_task/${urlVoToDelete.id}')
                );
                if (response.statusCode == 200 || response.statusCode == 204) {
                  if (mounted) {
                    setState(() {
                      _allUrlTasks.removeWhere((task) => task.id == urlVoToDelete.id);
                    });
                    if (urlVoToDelete.id != null) {
                      ref.read(taskStatusProvider.notifier).removeStatus(urlVoToDelete.id!);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('任务已删除')),
                    );
                  }
                } else {
                  throw Exception('Failed to delete task: ${response.statusCode}');
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('删除失败: ${e.toString()}')),
                  );
                }
              }
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
        return Consumer(
          builder: (context, ref, child) {
            final taskStatuses = ref.watch(taskStatusProvider);
            final taskStatusState = urlVo.id != null ? taskStatuses[urlVo.id] : null;

            return AlertDialog(
              title: const Text('任务详情'),
              content: SingleChildScrollView(
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
                          _buildStatusBadge(taskStatusState.status),
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

  Widget _buildStatusBadge(TaskStatus status) {
    Color color;
    String text = status.name;
    switch (status) {
      case TaskStatus.pending:
        color = Colors.grey;
        break;
      case TaskStatus.downloading:
        color = Colors.blue;
        break;
      case TaskStatus.extractingFrames:
        color = Colors.indigo;
        break;
      case TaskStatus.extractingAudio:
        color = Colors.purple;
        break;
      case TaskStatus.uploadingAudio:
        color = Colors.orange;
        break;
      case TaskStatus.uploadingFrames:
        color = Colors.deepOrange;
        break;
      case TaskStatus.completed:
        color = Colors.green;
        break;
      case TaskStatus.error:
        color = Colors.red;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }
}