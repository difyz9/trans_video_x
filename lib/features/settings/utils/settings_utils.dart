import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettingsUtils {
  // Copy settings to clipboard as JSON
  static Future<bool> exportSettingsToClipboard({
    required Map<String, dynamic> settings,
  }) async {
    try {
      final String settingsJson = jsonEncode(settings);
      await Clipboard.setData(ClipboardData(text: settingsJson));
      return true;
    } catch (e) {
      debugPrint('Error exporting settings: $e');
      return false;
    }
  }
  
  // Parse settings from JSON string
  static Map<String, dynamic>? importSettingsFromJson(String jsonString) {
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error importing settings: $e');
      return null;
    }
  }
  
  // Show haptic feedback for settings changes
  static void settingChangeFeedback() {
    HapticFeedback.lightImpact();
  }
  
  // Show haptic feedback for selections
  static void selectionFeedback() {
    HapticFeedback.selectionClick();
  }
  
  // Get a search index for settings
  static Map<String, List<String>> createSearchIndex() {
    return {
      'account': ['用户', '账户', '登录', '退出', '个人信息', '头像', 'profile', 'account', 'login'],
      'theme': ['主题', '颜色', '色彩', '暗黑模式', '亮度', '饱和度', 'dark mode', 'theme', 'color'],
      'language': ['语言', '多语言', '翻译', '国际化', 'language', 'localization'],
      'notification': ['通知', '提醒', '消息', 'notification', 'alert'],
      'about': ['关于', '版本', '更新', '信息', 'about', 'version', 'update'],
      'feedback': ['反馈', '建议', '问题', '联系', 'feedback', 'contact'],
    };
  }
  
  // Filter settings by search query
  static List<String> searchSettings(String query) {
    if (query.isEmpty) return [];
    
    final searchIndex = createSearchIndex();
    final results = <String>[];
    
    searchIndex.forEach((key, terms) {
      for (final term in terms) {
        if (term.toLowerCase().contains(query.toLowerCase())) {
          if (!results.contains(key)) {
            results.add(key);
          }
          break;
        }
      }
    });
    
    return results;
  }

  // First time visit detection key
  static const String firstVisitKey = 'settings_first_visit';
  
  // Animation durations
  static const Duration quickAnimationDuration = Duration(milliseconds: 150);
  static const Duration standardAnimationDuration = Duration(milliseconds: 300);
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);
  
  // Tooltip messages
  static const Map<String, String> tooltipMessages = {
    'colorBrightness': '调整主题颜色的亮度，左侧更暗，右侧更亮',
    'colorSaturation': '调整主题颜色的饱和度，左侧更灰，右侧更鲜艳',
    'undoChange': '撤销上一次设置更改',
    'exportSettings': '导出设置到剪贴板',
    'importSettings': '从剪贴板导入设置',
    'searchSettings': '搜索设置项',
    'accountLogin': '登录以使用更多功能',
    'accountLogout': '退出当前账号',
    'languageChange': '更改应用显示语言',
  };
}