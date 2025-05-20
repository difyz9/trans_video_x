import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:trans_video_x/core/constants/app_config.dart';
import 'package:trans_video_x/features/task/model/jexception.dart';

/// FFmpegWrapper 类封装了与 FFmpeg 和 ffprobe 可执行文件的交互逻辑。
/// 主要用于检查这些依赖是否存在以及执行视频转换操作。
class FFmpegWrapper {
  // checa se ffmpeg e ffprobe estão instalados na máquina
  /// 检查 FFmpeg 和 ffprobe 是否已安装在用户的机器上。
  ///
  /// 此方法会尝试运行 `ffmpeg -version` 和 `ffprobe -version` 命令。
  /// 如果命令成功执行 (exitCode == 0)，则认为相应的依赖已安装。
  ///
  /// 返回一个元组 (Tuple)，其中包含两个布尔值：
  /// - 第一个值表示 FFmpeg 是否已安装。
  /// - 第二个值表示 ffprobe 是否已安装。
  ///
  /// 此方法还会更新 AppConfig 中的依赖状态。
  static Future<(bool, bool)> verificarDependencias() async {
    bool ffmpeg = false; // 初始化 ffmpeg 安装状态为 false
    bool ffprobe = false; // 初始化 ffprobe 安装状态为 false

    // 检查 FFmpeg
    try {
      // 尝试运行 ffmpeg -version 命令
      final cmdFFmpeg = await Process.run('ffmpeg', ['-version']);
      // 如果命令退出码为 0，则表示 ffmpeg 已安装
      ffmpeg = cmdFFmpeg.exitCode == 0;
      // 如果 ffmpeg 未安装 (或命令执行失败)，则抛出 FFmpegException 异常
      if (!ffmpeg) throw FFmpegException(cmdFFmpeg.stderr);
    } catch (e) {
      // 如果在调试模式下，打印 FFmpeg 检查过程中的错误信息
      if (kDebugMode) {
        print("ffmpg error: $e");
      }
    }

    // 检查 ffprobe
    try {
      // 尝试运行 ffprobe -version 命令
      final cmdFFprobe = await Process.run('ffprobe', ['-version']);
      // 如果命令退出码为 0，则表示 ffprobe 已安装
      ffprobe = cmdFFprobe.exitCode == 0;
      // 如果 ffprobe 未安装 (或命令执行失败)，则抛出 FFmpegException 异常
      if (!ffprobe) throw FFmpegException(cmdFFprobe.stderr);
    } catch (e) {
      // 如果在调试模式下，打印 ffprobe 检查过程中的错误信息
      if (kDebugMode) {
        print("ffprobe error: $e");
      }
    }
    // 更新 AppConfig 中的依赖状态
    AppConfig.instance.setTemDeps(ffmpeg && ffprobe);
    // 返回 ffmpeg 和 ffprobe 的安装状态
    return (ffmpeg, ffprobe);
  }

  /// 将指定路径的视频文件转换为 H.264 编码 (通常是 .mp4 格式)。
  ///
  /// [nome] 是原始视频文件的名称 (例如 "video.webm")。
  /// [caminho] 是视频文件所在的目录路径。
  ///
  /// 此方法会：
  /// 1. 构建输入文件和输出文件的完整路径。输出文件会临时命名为 "output" + [nome]。
  /// 2. 使用 FFmpeg 执行转换命令：`ffmpeg -i [输入文件] -vcodec libx264 -acodec aac [输出文件]`。
  ///    - `-vcodec libx264` 指定视频编解码器为 H.264。
  ///    - `-acodec aac` 指定音频编解码器为 AAC (一种常见的与 H.264 配合使用的音频编码)。
  /// 3. 如果转换成功 (exitCode == 0)：
  ///    - 删除原始输入文件。
  ///    - 将转换后的输出文件重命名为原始文件名。
  /// 4. 如果转换过程中发生任何错误，则抛出 FFmpegException。
  static void converterParaH264(String nome, String caminho) async {
    try {
      // 构建原始输入文件的完整路径
      String caminhoDest = '$caminho/$nome';
      // 构建临时输出文件的完整路径 (在原始文件名基础上添加 "output" 前缀)
      String caminhoCopia = '$caminho/output$nome';
      // 定义 FFmpeg 转换命令的参数列表
      List<String> argsConversao = ['-i', caminhoDest, '-vcodec', 'libx264', '-acodec', 'aac', caminhoCopia];
      // 执行 FFmpeg 转换命令
      final cmdConversao = await Process.run('ffmpeg', argsConversao);
      // 如果命令退出码不为 0，表示转换失败，抛出异常
      if (cmdConversao.exitCode != 0) throw FFmpegException(cmdConversao.stderr);

      // 创建输入文件和输出文件的 File 对象
      File input = File(caminhoDest);
      File output = File(caminhoCopia);

      // 如果输入文件存在，则删除它
      if (input.existsSync()) input.deleteSync();
      // 如果输出文件存在，则将其重命名为原始输入文件的名称
      if (output.existsSync()) output.renameSync(caminhoDest);
    } catch (e) {
      // 如果在转换过程中发生任何错误，则抛出 FFmpegException
      throw FFmpegException('Erro ao converter para H264: $e');
    }
  }

  /// Extracts audio from a video file and saves it as an MP3.
  ///
  /// [inputVideoPath] is the full path to the input video file.
  /// [outputAudioPath] is the full path where the extracted audio (MP3) will be saved.
  ///
  /// This method uses FFmpeg to perform the audio extraction.
  /// The command executed is:
  /// `ffmpeg -hide_banner -ignore_unknown -y -i [inputVideoPath] -vn -ac 1 -b:a 192k -c:a libmp3lame [outputAudioPath]`
  ///
  /// Throws [FFmpegException] if the FFmpeg command fails.
  static Future<void> extractAudioFromVideo(String inputVideoPath, String outputAudioPath) async {
    try {
      List<String> args = [
        '-hide_banner',
        '-ignore_unknown',
        '-y', // Overwrite output files without asking
        '-i',
        inputVideoPath,
        '-vn', // No video
        '-ac',
        '1', // Mono audio
        '-b:a',
        '192k', // Audio bitrate
        '-c:a',
        'libmp3lame', // Audio codec
        outputAudioPath
      ];

      final result = await Process.run('ffmpeg', args);

      if (result.exitCode != 0) {
        throw FFmpegException('Failed to extract audio: ${result.stderr}');
      }
    } catch (e) {
      throw FFmpegException('Error extracting audio: $e');
    }
  }

  /// Extracts a single frame from a video file and saves it as an image.
  ///
  /// [inputVideoPath] is the full path to the input video file.
  /// [outputImagePath] is the full path where the extracted frame (image) will be saved.
  /// [timestamp] is the time in HH:MM:SS format (e.g., "00:00:05" for 5 seconds)
  /// from where the frame should be extracted.
  ///
  /// This method uses FFmpeg to perform the frame extraction.
  /// The command executed is:
  /// `ffmpeg -i [inputVideoPath] -ss [timestamp] -vframes 1 [outputImagePath]`
  ///
  /// Throws [FFmpegException] if the FFmpeg command fails.
  static Future<void> extractFrameFromVideo(String inputVideoPath, String outputImagePath, String timestamp) async {
    try {
      List<String> args = [
        '-i',
        inputVideoPath,
        '-ss',
        timestamp, // Time to seek to
        '-vframes',
        '1', // Extract only one frame
        outputImagePath
      ];

      final result = await Process.run('ffmpeg', args);

      if (result.exitCode != 0) {
        throw FFmpegException('Failed to extract frame: ${result.stderr}');
      }
    } catch (e) {
      throw FFmpegException('Error extracting frame: $e');
    }
  }
}
