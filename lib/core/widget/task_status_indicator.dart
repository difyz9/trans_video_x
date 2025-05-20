import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trans_video_x/features/task/model/task_status.dart';
import 'package:trans_video_x/features/task/provider/task_provider.dart';

class TaskStatusOverview extends ConsumerWidget {
  const TaskStatusOverview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskStatuses = ref.watch(taskStatusProvider);
    final isPolling = ref.watch(isPollingProvider);
    
    if (taskStatuses.isEmpty && !isPolling) {
      return const SizedBox.shrink(); // Nothing to show
    }
    
    // Count tasks by status
    int pending = 0;
    int inProgress = 0;
    int completed = 0;
    int failed = 0;
    
    for (final status in taskStatuses.values) {
      if (status.status == TaskStatus.pending) {
        pending++;
      } else if (status.status == TaskStatus.completed) {
        completed++;
      } else if (status.status == TaskStatus.error) {
        failed++;
      } else {
        inProgress++;
      }
    }
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '任务概览',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isPolling)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('轮询中'),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusCount(context, '等待中', pending, Colors.grey),
                _buildStatusCount(context, '处理中', inProgress, Colors.blue),
                _buildStatusCount(context, '已完成', completed, Colors.green),
                _buildStatusCount(context, '失败', failed, Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusCount(BuildContext context, String label, int count, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: color.withOpacity(0.2),
          child: Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
