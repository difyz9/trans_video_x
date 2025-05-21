import 'package:hive_flutter/hive_flutter.dart';
import 'package:trans_video_x/models/add_url_model.dart';
import 'package:trans_video_x/core/hive/add_url_adapter.dart';
import 'package:trans_video_x/core/constants/app_constants.dart';
import 'package:trans_video_x/models/task_model.dart';

/// 初始化Hive数据库
Future<void> initHive() async {
  // 初始化Hive
  await Hive.initFlutter();
  
  // 注册适配器
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(AddUrlAdapter());
      Hive.registerAdapter(TaskModelAdapter()); // 这是关键步骤！

  }
  
  // 打开box
  await Hive.openBox<AddUrlModel>(AppConstants.addUrlModelBoxName);
}
