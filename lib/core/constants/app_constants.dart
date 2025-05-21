class AppConstants {
  static const String appName = 'Admin Dashboard';
  
  // http://127.0.0.1:5678/api/v1/version
  // API endpoints
  // static const String baseUrl = 'https://www.coding520.top/dev_api';
  static const String baseUrl = 'http://127.0.0.1:8081';
  // 使用 mockbin.org 作为模拟更新服务器
  static const String updateBaseUrl = 'http://127.0.0.1:5678';

  // Feature flags
  static const bool enableAutoUpdate = true;
  

   static const String addUrlModelBoxName = 'addUrlModels';

  // Update check intervals
  static const Duration updateCheckInterval = Duration(hours: 24);
  
  // Shared Preferences keys
  static const String lastUpdateCheckKey = 'last_update_check';
  static const String ignoredVersionKey = 'ignored_version';
  
  // 调试模式下，始终检查更新
  static const bool alwaysCheckUpdateOnDebug = true;
}


String padrao = 'Padrão';

List<String> formatosConversao = [
  "aac",
  "alac",
  "m4a",
  "mp3",
  "mpg",
  "opus",
  "wav",
];

List<String> extensoesH264 = [
  'mp4',
  'mkv',
  'mov',
  'ts',
  'flv',
  'avi'
];