import 'dart:io';
import 'package:path_provider/path_provider.dart';

// 定义常量，用于字节单位换算
const int KB = 1024;
const int MB = KB * 1024;
const int GB = MB * 1024;

// 定义常量，用于字节单位换算
const int kb = 1024;
const int mb = 1024 * 1024;
const int gb = 1024 * 1024 * 1024;

class FileUtils {
  // 私有构造函数，确保该类为单例模式
  FileUtils._();

  // 单例实例
  static final FileUtils _instance = FileUtils._();

  // 获取单例实例的静态方法
  static FileUtils get instance => _instance;







  // 保存 JSON 数据到文件的方法
  Future<void> saveJsonToFile(String jsonData, String fileName) async {
    try {
      // 获取应用的文档目录
      // Directory appDocDir = await getApplicationDocumentsDirectory();
      // 获取应用支持目录
      //   /Users/apple/Library/Application Support/com.example.flaskExample/user.json
      // com.ol.pencil.app
      // com.example.flaskExample
      Directory appSupportDir = await getApplicationSupportDirectory();
      String appDocPath = appSupportDir.path;

      // 构建文件的完整路径
      String filePath = '$appDocPath/$fileName';

      // 创建一个 File 对象
      File file = File(filePath);

      // 将 JSON 字符串写入文件
      await file.writeAsString(jsonData);

      print('JSON 数据已成功保存到 $filePath');
    } catch (e) {
      print('保存文件时出错: $e');
    }
  }


// 拷贝文件到新的路径
  Future<void> copyFile(String sourcePath, String destinationPath) async {
    final sourceFile = File(sourcePath);
    final destinationFile = File(destinationPath);

    try {
      await sourceFile.copy(destinationPath);
      print('File copied successfully to $destinationPath');
    } catch (e) {
      print('Error copying file: $e');
    }
  }




/// 根据文件路径名返回文件大小（以 M 或 G 为单位）
/// 如果文件不存在，返回 '0 B'
Future<String> getFileSizeInHumanReadable(String filePath) async {
  final file = File(filePath);
  if (await file.exists()) {
    final int sizeInBytes = await file.length();

    if (sizeInBytes >= GB) {
      // 如果文件大小大于等于 1GB，转换为 GB 并保留两位小数
      final double sizeInGB = sizeInBytes / GB;
      return '${sizeInGB.toStringAsFixed(2)} G';
    } else if (sizeInBytes >= MB) {
      // 如果文件大小大于等于 1MB，转换为 MB 并保留两位小数
      final double sizeInMB = sizeInBytes / MB;
      return '${sizeInMB.toStringAsFixed(2)} M';
    } else if (sizeInBytes >= KB) {
      // 如果文件大小大于等于 1KB，转换为 KB 并保留两位小数
      final double sizeInKB = sizeInBytes / KB;
      return '${sizeInKB.toStringAsFixed(2)} KB';
    } else {
      // 文件大小小于 1KB，以字节为单位
      return '$sizeInBytes B';
    }
  }
  return '0 B';
}
// 判断文件路径是否有特殊字符
bool hasSpecialCharacters(String path) {
  // 定义允许的字符范围，这里允许字母、数字、斜杠、反斜杠、点
  final RegExp allowedChars = RegExp(r'^[a-zA-Z0-9/\\.]+$');
  return !allowedChars.hasMatch(path);
}
}
