import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Define a simple data model for a task
class Task {
  final String title;
  final String description;
  final String createdDate;
  final String responsiblePerson;
  final String? estimatedCompletionDate;
  final String? completionDate;
  final String? failureReason;
  final String status; // "处理中", "已完成", "失败"

  Task({
    required this.title,
    required this.description,
    required this.createdDate,
    required this.responsiblePerson,
    this.estimatedCompletionDate,
    this.completionDate,
    this.failureReason,
    required this.status,
  });
}

@RoutePage()
class Task03Screen extends ConsumerStatefulWidget {
  const Task03Screen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _Task03ScreenState();
}

class _Task03ScreenState extends ConsumerState<Task03Screen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock data - replace with your actual data source
  final List<Task> _allTasks = [
    Task(
      title: '数据分析报告生成任务',
      description: '分析过去30天的用户行为数据, 生成用户画像和转化漏斗分析报告',
      createdDate: '2023-12-20 14:30',
      responsiblePerson: '张文浩',
      estimatedCompletionDate: '2023-12-21 14:30',
      status: '处理中',
    ),
    Task(
      title: '系统性能优化任务',
      description: '优化系统响应速度, 提升用户体验, 包括数据库查询优化和缓存策略调整',
      createdDate: '2023-12-19 10:15',
      responsiblePerson: '李思琪',
      completionDate: '2023-12-20 16:45',
      status: '已完成',
    ),
    Task(
      title: '用户数据迁移任务',
      description: '将用户数据从旧系统迁移到新系统, 确保数据完整性和一致性',
      createdDate: '2023-12-18 09:00',
      responsiblePerson: '王建国',
      failureReason: '数据格式不兼容',
      status: '失败',
    ),
    Task(
      title: '新功能开发任务',
      description: '开发用户反馈的新功能模块, 包括需求分析、设计和开发实现',
      createdDate: '2023-12-20 11:20',
      responsiblePerson: '陈雨萱',
      estimatedCompletionDate: '2023-12-25 18:00',
      status: '处理中',
    ),
  ];

  List<Task> _getFilteredTasks(String status) {
    if (status == '全部') {
      return _allTasks;
    }
    return _allTasks.where((task) => task.status == status).toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('任务列表'), // You can customize the title
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '全部 24'), // Replace with dynamic counts
            Tab(text: '处理中 8'),
            Tab(text: '已完成 12'),
            Tab(text: '失败 4'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTaskList(_getFilteredTasks('全部')),
          _buildTaskList(_getFilteredTasks('处理中')),
          _buildTaskList(_getFilteredTasks('已完成')),
          _buildTaskList(_getFilteredTasks('失败')),
        ],
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks) {
    if (tasks.isEmpty) {
      return const Center(child: Text('没有任务'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return _buildTaskItem(tasks[index]);
      },
    );
  }

  Widget _buildTaskItem(Task task) {
    Color statusColor;
    String statusText = task.status;

    switch (task.status) {
      case '处理中':
        statusColor = Colors.blue.shade100;
        break;
      case '已完成':
        statusColor = Colors.green.shade100;
        break;
      case '失败':
        statusColor = Colors.red.shade100;
        break;
      default:
        statusColor = Colors.grey.shade100;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
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
                        color: task.status == '处理中'
                            ? Colors.blue.shade800
                            : task.status == '已完成'
                                ? Colors.green.shade800
                                : task.status == '失败'
                                    ? Colors.red.shade800
                                    : Colors.grey.shade800,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(task.description, style: TextStyle(color: Colors.grey.shade700)),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text('创建时间: ${task.createdDate}', style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(width: 16),
                Icon(Icons.person_outline, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text('负责人: ${task.responsiblePerson}', style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
            const SizedBox(height: 4),
            if (task.estimatedCompletionDate != null)
              Row(
                children: [
                  Icon(Icons.timer_outlined, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text('预计完成: ${task.estimatedCompletionDate}', style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            if (task.completionDate != null)
              Row(
                children: [
                  Icon(Icons.check_circle_outline, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text('完成时间: ${task.completionDate}', style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            if (task.failureReason != null)
              Row(
                children: [
                  Icon(Icons.error_outline, size: 16, color: Colors.red.shade600),
                  const SizedBox(width: 4),
                  Text('失败原因: ${task.failureReason}', style: TextStyle(color: Colors.red.shade600)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}