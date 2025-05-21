import 'package:flutter_riverpod/flutter_riverpod.dart'; // Add this import
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trans_video_x/models/add_url_model.dart';
import 'package:trans_video_x/core/hive/add_url_adapter.dart';
import 'package:trans_video_x/core/constants/app_constants.dart';
import 'package:trans_video_x/models/task_model.dart';
import 'package:trans_video_x/models/task_box_provider.dart';

/// 初始化Hive数据库
Future<void> initHive() async {
  // 初始化Hive
  await Hive.initFlutter();
  
  if (!Hive.isAdapterRegistered(TaskModelAdapter().typeId)) { // Check by typeId for TaskModelAdapter
    Hive.registerAdapter(TaskModelAdapter()); // 这是关键步骤！
  }
  if (!Hive.isAdapterRegistered(AddUrlAdapter().typeId)) { // Check by typeId for AddUrlAdapter
    Hive.registerAdapter(AddUrlAdapter());
  }
    const String tasksBoxName = 'tasksBox'; // Define or import your TaskModel's box name

  // DEVELOPMENT ONLY: Delete the tasks box to handle schema changes.
  // Remove or comment out for production.
  await Hive.deleteBoxFromDisk(tasksBoxName);
  print('INFO: Deleted $tasksBoxName for schema reset.');

    final container = ProviderContainer();

  // 确保 Hive Box 在 ViewModel 尝试使用它之前已经打开
  await container.read(taskBoxProvider.future); 
  
  // 读取 provider 以创建 TaskSyncViewModel 实例并开始监听
  container.read(taskSyncViewModelProvider); 

  
  // 打开box
  await Hive.openBox<AddUrlModel>(AppConstants.addUrlModelBoxName);
}
