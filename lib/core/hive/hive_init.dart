import 'package:hive_flutter/hive_flutter.dart';
import 'package:trans_video_x/models/add_url_model.dart';
import 'package:trans_video_x/core/hive/add_url_adapter.dart';

/// 初始化Hive数据库
Future<void> initHive() async {
  // 初始化Hive
  await Hive.initFlutter();
  
  // 注册适配器
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(AddUrlAdapter());
  }
  
  // 打开box
  await Hive.openBox<AddUrlModel>('urlVos');
}
