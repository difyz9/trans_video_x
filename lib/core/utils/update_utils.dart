import 'dart:io';
import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:http/http.dart' as http;
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';

void checkForUpdates() async {
  final updateUrl = 'https://example.com/update.zip'; // 更新包下载地址
  final versionCheckUrl = 'https://example.com/version.json'; // 版本检查地址

  try {
    // 检查是否有新版本
    final response = await http.get(Uri.parse(versionCheckUrl));
    if (response.statusCode == 200) {
      final remoteVersion = response.body; // 假设返回的是版本号
      final localVersion = '1.0.0'; // 本地版本号

      if (remoteVersion != localVersion) {
        // 下载更新包
        final appDir = await getApplicationSupportDirectory();
        final updateFile = File('${appDir.path}/update.zip');
        await downloadFile(updateUrl, updateFile.path);

        // 解压更新包
        await extractAndReplace(updateFile.path, appDir.path);

        // 重启应用
        restartApp();
      } else {
        print('Already up to date.');
      }
    }
  } catch (e) {
    print('Update failed: $e');
  }
}

Future<void> downloadFile(String url, String savePath) async {
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final file = File(savePath);
    await file.writeAsBytes(response.bodyBytes);
  } else {
    throw Exception('Failed to download update');
  }
}

Future<void> extractAndReplace(String zipPath, String extractPath) async {
  final bytes = await File(zipPath).readAsBytes();
  final archive = ZipDecoder().decodeBytes(bytes);

  for (final file in archive) {
    final filename = '$extractPath/${file.name}';
    if (file.isFile) {
      final outFile = File(filename);
      await outFile.create(recursive: true);
      await outFile.writeAsBytes(file.content);
    }
  }
}

void restartApp() {
  // 关闭当前应用
  appWindow.close();

  // 启动新版本应用
  final appPath = Platform.resolvedExecutable;
  Process.start(appPath, []);
}