import 'dart:async';
import 'package:flutter/foundation.dart';

// 字幕条目模型
class SubtitleEntry {
  final Duration start;
  final Duration end;
  final String data;
  final String audioUrl;
  final String? id; // 可选ID

  SubtitleEntry({
    required this.start, 
    required this.end, 
    required this.audioUrl,
    required this.data, 
    this.id
  });
}

// 字幕提供者
class SubtitleProvider {
  // 从SRT格式解析字幕
  static Future<List<SubtitleEntry>> fromSrt(String srtContent) async {
    final List<SubtitleEntry> entries = [];
    final List<String> lines = srtContent.split('\n');

    int index = 0;
    while (index < lines.length) {
      // 跳过空行和序号
      while (index < lines.length && lines[index].trim().isEmpty) {
        index++;
      }
      if (index >= lines.length) break;
      
      // 跳过序号行
      index++;
      if (index >= lines.length) break;

      // 解析时间行
      final String timeLine = lines[index++];
      final timeMatch = RegExp(r'(\d{2}):(\d{2}):(\d{2}),(\d{3}) --> (\d{2}):(\d{2}):(\d{2}),(\d{3})').firstMatch(timeLine);
      
      if (timeMatch == null) continue;
      
      final startHour = int.parse(timeMatch.group(1)!);
      final startMin = int.parse(timeMatch.group(2)!);
      final startSec = int.parse(timeMatch.group(3)!);
      final startMs = int.parse(timeMatch.group(4)!);
      
      final endHour = int.parse(timeMatch.group(5)!);
      final endMin = int.parse(timeMatch.group(6)!);
      final endSec = int.parse(timeMatch.group(7)!);
      final endMs = int.parse(timeMatch.group(8)!);

      final startDuration = Duration(
        hours: startHour,
        minutes: startMin,
        seconds: startSec,
        milliseconds: startMs,
      );
      
      final endDuration = Duration(
        hours: endHour,
        minutes: endMin,
        seconds: endSec,
        milliseconds: endMs,
      );

      // 读取字幕文本
      String subtitleText = '';
      while (index < lines.length && lines[index].trim().isNotEmpty) {
        subtitleText += (subtitleText.isEmpty ? '' : '\n') + lines[index];
        index++;
      }

      // 从字幕文本提取ID
      final idMatch = RegExp(r'\[(\d+)\]').firstMatch(subtitleText);
      final String? id = idMatch?.group(1);

      entries.add(SubtitleEntry(
        start: startDuration,
        end: endDuration,
        data: subtitleText,
        audioUrl: '', // 这里可以添加音频URL
        id: id,
      ));
    }

    return entries;
  }

  // 从WebVTT格式解析字幕
  static Future<List<SubtitleEntry>> fromWebVTT(String vttContent) async {
    final List<SubtitleEntry> entries = [];
    
    // 替换可能的BOM标记和特殊字符
    vttContent = _cleanContent(vttContent);
    
    final List<String> lines = vttContent.split('\n');

    debugPrint('WebVTT 内容行数: ${lines.length}');
    
    // 适应更多格式的VTT文件
    int index = 0;
    // 跳过WebVTT标头 (可能包含WEBVTT标记)
    while (index < lines.length) {
      final line = lines[index].trim();
      // 打印前几行内容以便调试
      if (index < 5) {
        debugPrint('行 $index: "$line"');
      }
      
      // 寻找时间戳行的开始
      if (line.isEmpty || line.startsWith('WEBVTT') || !_containsTimestamp(line)) {
        index++;
        continue;
      }
      break;
    }
    
    debugPrint('开始解析字幕，从行 $index');

    while (index < lines.length) {
      // 跳过空行或cue标识符
      while (index < lines.length && lines[index].trim().isEmpty) {
        index++;
      }
      if (index >= lines.length) break;
      
      // 如果不是时间戳行，可能是cue id，跳过
      if (!_containsTimestamp(lines[index])) {
        index++;
        continue;
      }

      // 解析时间行
      final String timeLine = lines[index++];
      debugPrint('解析时间行: $timeLine');
      
      // 支持两种常见的时间格式: 00:00:00.000 和 00:00.000
      final timeMatch = RegExp(r'((?:\d{2}:)?\d{2}:\d{2})[\.,](\d{3}) --> ((?:\d{2}:)?\d{2}:\d{2})[\.,](\d{3})').firstMatch(timeLine);
      
      if (timeMatch == null) {
        debugPrint('无法匹配时间行: $timeLine');
        continue;
      }
      
      // 解析开始时间
      final startTimeStr = timeMatch.group(1)!;
      final startMs = int.parse(timeMatch.group(2)!);
      
      // 解析结束时间
      final endTimeStr = timeMatch.group(3)!;
      final endMs = int.parse(timeMatch.group(4)!);
      
      final startDuration = _parseDuration(startTimeStr, startMs);
      final endDuration = _parseDuration(endTimeStr, endMs);
      
      debugPrint('解析时间: $startDuration --> $endDuration');

      // 读取字幕文本直到下一个空行
      String subtitleText = '';
      while (index < lines.length && lines[index].trim().isNotEmpty) {
        subtitleText += (subtitleText.isEmpty ? '' : '\n') + lines[index];
        index++;
      }
      
      debugPrint('字幕文本: $subtitleText');

      // 从字幕文本提取ID
      String? id;
      final idMatch = RegExp(r'\[(\d+)\]').firstMatch(subtitleText);
      if (idMatch != null) {
        id = idMatch.group(1);
        debugPrint('提取到ID: $id');
      } else {
        debugPrint('未提取到ID');
      }

      entries.add(SubtitleEntry(
        start: startDuration,
        end: endDuration,
        audioUrl: '', // 这里可以添加音频URL
        data: subtitleText,
        id: id,
      ));
    }
    
    debugPrint('解析完成，共 ${entries.length} 条字幕');
    return entries;
  }
  
  // 清理字幕内容，移除BOM和不可见字符
  static String _cleanContent(String content) {
    // 移除UTF-8 BOM标记 (EF BB BF)
    if (content.isNotEmpty && content.codeUnitAt(0) == 0xFEFF) {
      content = content.substring(1);
    }
    
    // 移除不可打印字符
    content = content.replaceAll(RegExp(r'[\x00-\x09\x0B\x0C\x0E-\x1F\x7F]'), '');
    
    return content;
  }
  
  // 判断字符串是否包含时间戳
  static bool _containsTimestamp(String line) {
    return RegExp(r'\d{2}:\d{2}[:.]\d{3} --> \d{2}:\d{2}[:.]\d{3}').hasMatch(line) ||
           RegExp(r'\d{2}:\d{2}:\d{2}[:.]\d{3} --> \d{2}:\d{2}:\d{2}[:.]\d{3}').hasMatch(line);
  }
  
  // 解析时间字符串
  static Duration _parseDuration(String timeStr, int ms) {
    final parts = timeStr.split(':');
    
    if (parts.length == 3) {
      // 格式 hh:mm:ss
      return Duration(
        hours: int.parse(parts[0]),
        minutes: int.parse(parts[1]),
        seconds: int.parse(parts[2]),
        milliseconds: ms,
      );
    } else if (parts.length == 2) {
      // 格式 mm:ss
      return Duration(
        minutes: int.parse(parts[0]),
        seconds: int.parse(parts[1]),
        milliseconds: ms,
      );
    }
    
    // 默认情况
    return Duration(milliseconds: ms);
  }
}
