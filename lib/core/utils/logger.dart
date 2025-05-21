import 'package:flutter/foundation.dart';

/// 日志工具类
///
/// 提供统一的日志记录接口，支持：
/// 1. 不同级别的日志（info、debug、error）
/// 2. 标签分类
/// 3. 统一的日志格式
class Logger {
  const Logger._();

  /// 记录信息日志
  ///
  /// [tag] 日志标签，用于标识日志来源
  /// [message] 日志消息
  static void info(String tag, String message) {
    if (kDebugMode) {
      print('💡 [$tag] $message');
    }
  }

  /// 记录调试日志
  ///
  /// [tag] 日志标签，用于标识日志来源
  /// [message] 调试消息
  static void debug(String tag, String message) {
    if (kDebugMode) {
      print('🔍 [$tag] $message');
    }
  }

  /// 记录错误日志
  ///
  /// [tag] 日志标签，用于标识日志来源
  /// [message] 错误消息
  /// [error] 错误对象（可选）
  static void error(String tag, String message, [dynamic error]) {
    if (kDebugMode) {
      if (error != null) {
        print('❌ [$tag] $message\n$error');
      } else {
        print('❌ [$tag] $message');
      }
    }
  }
}
