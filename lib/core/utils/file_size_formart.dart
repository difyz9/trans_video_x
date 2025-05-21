import 'dart:io';

class FileSizeFormatter {
  // 定义常量，用于字节单位换算
  static const int kb = 1024;
  static const int mb = 1024 * 1024;
  static const int gb = 1024 * 1024 * 1024;

  // 格式化文件大小的静态方法
  static String formatFileSize(int bytes) {
    if (bytes >= gb) {
      // 如果文件大小大于等于 1GB，转换为 GB 并保留两位小数
      return '${(bytes / gb).toStringAsFixed(2)} G';
    } else if (bytes >= mb) {
      // 如果文件大小大于等于 1MB，转换为 MB 并保留两位小数
      return '${(bytes / mb).toStringAsFixed(2)} M';
    } else if (bytes >= kb) {
      // 如果文件大小大于等于 1KB，转换为 KB 并保留两位小数
      return '${(bytes / kb).toStringAsFixed(2)} KB';
    } else {
      // 文件大小小于 1KB，以字节为单位
      return '$bytes B';
    }
  }

  // 直接从文件获取并格式化文件大小的静态方法
  static String formatFile(File file) {
    try {
      int fileSizeInBytes = file.statSync().size;
      return formatFileSize(fileSizeInBytes);
    } catch (e) {
      print('获取文件大小时出错: $e');
      return 'Error';
    }
  }
}
