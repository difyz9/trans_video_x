import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../services/subtitle_service.dart';
import 'package:trans_video_x/features/video/viewmodel/video_info_view_model.dart';
import 'package:trans_video_x/core/widget/window_title_bar.dart';
import 'package:trans_video_x/features/video/components/settings_panel.dart';

import 'dart:async';

// 字幕显示模式
enum SubtitleMode { off, chinese, original, bilingual }

@RoutePage()
class PlaymediaScreen extends ConsumerStatefulWidget {
  final String? videoId; // 添加视频ID参数

  const PlaymediaScreen({super.key, this.videoId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PlaymediaScreenState();
}

class _PlaymediaScreenState extends ConsumerState<PlaymediaScreen> {
  // Media player instance - changed from late final to nullable
  Player? player;
  // Video controller
  VideoController? controller;
  double _dragStartPos = 0;
  Duration? _dragStartTime;
  bool _isDragging = false;
  int _seekAmount = 0; // 单位：秒
  // 设置面板相关状态
  bool _isSettingsPanelVisible = false;
  int? _currentSubmenuIndex;

  // Check if MediaKit is supported on this platform
  final bool isMediaKitSupported =
      !kIsWeb &&
      (Platform.isIOS ||
          Platform.isMacOS ||
          Platform.isWindows ||
          Platform.isLinux ||
          Platform.isAndroid);

  bool isInitialized = false;
  bool hasError = false;
  String errorMessage = '';

  // Video and subtitle URLs - will be populated by API
  String videoUrl = "";
  String subtitleUrl = "";

  bool isPlaying = false;
  bool isFullScreen = false;
  bool isSubtitlesEnabled = true;
  bool _stableVolume = false;
  bool _showAnnotations = true;
  // 字幕音频相关
  Player? audioPlayer; // 用于播放字幕音频
  List<SubtitleEntry> subtitles = []; // 解析后的字幕列表
  int currentSubtitleIndex = -1; // 当前播放的字幕索引
  bool isLoadingSubtitles = false; // 是否正在加载字幕
  bool enableSubtitleAudio = true; // 是否启用字幕音频

  // 音频基础URL - 将在获取视频信息后更新
  String audioBaseUrl = "";
  // 字幕显示模式设置
  SubtitleMode _subtitleMode = SubtitleMode.chinese; // 默认显示中文字幕
  // 播放速度相关变量
  double userPlaybackSpeed = 1.0; // 用户设置的播放速度
  double currentPlaybackSpeed = 1.0; // 当前实际播放速度
  bool isAdjustingForAudio = false; // 是否正在为音频调整速度
  bool isAudioPlaying = false; // 音频是否正在播放
  bool isAudioCompleted = true; // 音频是否播放完成
  Duration? currentAudioDuration; // 当前音频的持续时间
  bool preventSubtitleRepeat = false; // 防止重复播放同一字幕
  int lastPlayedSubtitleIndex = -1; // 上一次播放的字幕索引

  // 音频预加载和缓存
  final Map<String, String> _audioCachePaths = {}; // 缓存音频文件路径
  final Set<int> _preloadingAudioIds = {}; // 正在预加载的音频ID列表
  final int _preloadAheadCount = 3; // 预加载未来几条字幕的音频

  // UI控制相关
  bool _isUserActive = true;
  Timer? _userActivityTimer;
  bool _isBuffering = false;

  // 按钮响应区域大小
  final double buttonSize = 48.0;

  String _currentSubtitleModeText = '字幕 (1)';
  String _currentSleepTimer = '关闭';
  String _currentPlaybackSpeed = '正常';
  String _currentQuality = '自动 (1080p HD)';

  // 在类的顶部添加调试模式标志
  final bool isDebugMode = false; // 设置为true开启调试信息显示

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 首先加载视频信息，然后初始化播放器
      _loadFilesFromVideoId();
    });
    // 启动用户活动监控
    _startUserActivityMonitoring();
  }

  // 清理并重置播放器状态
  void _resetPlayerState() {
    debugPrint('重置播放器状态');
    
    // 停止定时器
    _userActivityTimer?.cancel();
    
    // 重置播放速度相关变量
    userPlaybackSpeed = 1.0;
    currentPlaybackSpeed = 1.0;
    isAdjustingForAudio = false;
    isAudioPlaying = false;
    isAudioCompleted = true;
    currentAudioDuration = null;
    preventSubtitleRepeat = false;
    lastPlayedSubtitleIndex = -1;

    // 清空缓存和预加载状态
    _audioCachePaths.clear();
    _preloadingAudioIds.clear();

    // 清空视频和字幕URL
    videoUrl = "";
    subtitleUrl = "";
    audioBaseUrl = "";

    // 停止音频播放
    if (audioPlayer != null) {
      audioPlayer!.stop();
      audioPlayer!.dispose();
      audioPlayer = null;
    }

    // 停止和清理视频播放器
    if (player != null) {
      player!.stop();
      player!.dispose();
      player = null;
    }

    // 清理控制器
    controller = null;

    // 重置其他状态
    setState(() {
      isInitialized = false;
      hasError = false;
      errorMessage = '';
      isPlaying = false;
      currentSubtitleIndex = -1;
      subtitles = [];
      _isBuffering = false;
      _isDragging = false;
      _seekAmount = 0;
      _isSettingsPanelVisible = false;
      _currentSubmenuIndex = null;
      _isUserActive = true;
    });
    
    // 重新启动用户活动监控
    _startUserActivityMonitoring();
  }

  @override
  void didUpdateWidget(PlaymediaScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 检查视频ID是否变更
    if (widget.videoId != oldWidget.videoId) {
      debugPrint('视频ID已更改：${oldWidget.videoId} -> ${widget.videoId}');

      // 彻底重置播放器状态
      _resetPlayerState();

      // 加载新视频
      _loadFilesFromVideoId();
    }
  }

  // 监控用户活动，在5秒无操作后隐藏控件
  void _startUserActivityMonitoring() {
    _resetUserActivityTimer();
  }

  void _resetUserActivityTimer() {
    // 取消现有定时器
    _userActivityTimer?.cancel();

    setState(() {
      _isUserActive = true;
    });

    // 创建新定时器
    _userActivityTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && isPlaying) {
        setState(() {
          _isUserActive = false;
        });
      }
    });
  }

  // 用户活动时调用
  void _onUserActivity() {
    _resetUserActivityTimer();
  }

  // 根据视频ID加载文件
  Future<void> _loadFilesFromVideoId() async {
    if (widget.videoId == null || widget.videoId!.isEmpty) {
      setState(() {
        hasError = true;
        errorMessage = 'No video ID provided';
      });
      return;
    }

    try {
      final String videoId = widget.videoId!;

      // 使用 ViewModel 获取视频信息
      await ref
          .read(videoInfoViewModelProvider.notifier)
          .fetchVideoInfo(videoId);

      // 获取视频信息结果并正确处理AsyncValue
      final videoInfoState = ref.read(videoInfoViewModelProvider);

      print("video_id = ${videoId}" );

      // 使用AsyncValue的when方法安全地处理不同状态
      videoInfoState.when(
        data: (videoInfo) async {
          // 成功获取数据
          debugPrint('Received videoInfo: $videoInfo');

          if (videoInfo != null) {
            final videoData = videoInfo;
            final videoUrl = videoData.mediaUrl;
            final srtUrl = videoData.zhSrt;

            if (videoUrl!.isNotEmpty) {
              // 更新视频和字幕URL
              setState(() {
                this.videoUrl = videoUrl;
                this.subtitleUrl = srtUrl;
                // 设置音频基础URL
                audioBaseUrl =
                    "https://dify01-1253459663.cos.ap-guangzhou.myqcloud.com/media/$videoId/audio/${videoId}_";
              });

              // 初始化播放器
              await _initializePlayer();

              // 如果有字幕URL，加载字幕文件
              if (srtUrl.isNotEmpty) {
                await _loadSubtitles();
              }
            } else {
              setState(() {
                hasError = true;
                errorMessage = 'Video URL is empty';
              });
            }
          } else {
            setState(() {
              hasError = true;
              errorMessage = 'VideoInfo is null';
            });
          }
        },
        error: (error, stackTrace) {
          // 处理错误
          setState(() {
            hasError = true;
            errorMessage = 'Failed to load video info: $error';
          });
          debugPrint('VideoInfo error: $error');
          debugPrint('Stack trace: $stackTrace');
        },
        loading: () {
          debugPrint('Loading video info...');
        },
      );
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = 'Error loading video: $e';
      });
      debugPrint('Failed to load video: $e');
    }
  }

  Future<void> _loadSubtitles() async {
    if (subtitleUrl.isEmpty) return;

    setState(() {
      isLoadingSubtitles = true;
    });

    try {
      debugPrint('开始加载字幕: $subtitleUrl');

      // 获取字幕文件的二进制数据
      final response = await http.get(Uri.parse(subtitleUrl));
      debugPrint('HTTP 状态码: ${response.statusCode}');

      if (response.statusCode == 200) {
        String? subtitleData;
        List<SubtitleEntry> parsedSubtitles = [];

        // 尝试用 UTF-8 解码
        try {
          subtitleData = utf8.decode(response.bodyBytes);
          debugPrint('UTF-8 解码成功');
        } catch (e) {
          debugPrint('UTF-8 解码失败: $e');

          // 尝试用 Latin-1 (ISO-8859-1) 解码
          try {
            subtitleData = latin1.decode(response.bodyBytes);
            debugPrint('Latin-1 解码成功');
          } catch (e) {
            debugPrint('Latin-1 解码失败: $e');

            // 最后尝试用系统默认编码
            subtitleData = String.fromCharCodes(response.bodyBytes);
            debugPrint('使用默认编码解码');
          }
        }

        if (subtitleData != null) {
          debugPrint(
            '字幕内容前100个字符: ${subtitleData.substring(0, subtitleData.length > 100 ? 100 : subtitleData.length)}',
          );

          // 解析字幕文件 (支持SRT或VTT格式)
          if (subtitleUrl.toLowerCase().endsWith('.srt')) {
            parsedSubtitles = await SubtitleProvider.fromSrt(subtitleData);
          } else if (subtitleUrl.toLowerCase().endsWith('.vtt')) {
            parsedSubtitles = await SubtitleProvider.fromWebVTT(subtitleData);
          }

          setState(() {
            subtitles = parsedSubtitles;
          });

          if (subtitles.isNotEmpty) {
            debugPrint('成功加载 ${subtitles.length} 条字幕');
            debugPrint('第一条字幕: ${subtitles[0].data}');
          } else {
            debugPrint('字幕列表为空，检查解析是否正确');
          }
        }

        // 初始化音频播放器
        if (audioPlayer == null) {
          audioPlayer = Player();
        }
      } else {
        debugPrint('加载字幕失败: HTTP状态 ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('加载字幕出错: $e');
    } finally {
      setState(() {
        isLoadingSubtitles = false;
      });
    }
  }

  Future<void> _initializePlayer() async {
    if (videoUrl.isEmpty) {
      setState(() {
        hasError = true;
        errorMessage = 'No video URL available';
      });
      return;
    }

    try {
      if (isMediaKitSupported) {
        // 确保先释放旧的player实例
        if (player != null) {
          await player!.dispose();
          player = null;
        }

        // Create player instance - no longer using late initialization
        player = Player();
        controller = VideoController(player!);
        player?.setVolume(1.0);

        // 监听播放位置变化，用于检测当前字幕
        player!.stream.position.listen(_checkCurrentSubtitle);

        // 监听缓冲状态
        player!.stream.buffering.listen((isBuffering) {
          setState(() {
            _isBuffering = isBuffering;
          });
        });

        // 初始化音频播放器，并设置监听
        if (audioPlayer == null) {
          audioPlayer = Player();

          // 监听音频播放完成事件
          audioPlayer!.stream.completed.listen((completed) {
            if (completed) {
              _onAudioCompleted();
            }
          });

          // 监听音频播放状态
          audioPlayer!.stream.playing.listen((playing) {
            setState(() {
              isAudioPlaying = playing;
            });
          });
        }

        // First open the media source
        await player!.open(Media(videoUrl));

        // 如果有字幕URL，加载字幕但不设置内置字幕轨道
        if (subtitleUrl.isNotEmpty) {
          await _loadSubtitles(); // 只加载字幕以供我们自定义显示
          // 不再调用 player!.setSubtitleTrack() 来避免双重字幕显示
        }

        // Start playing with default speed
        await player!.setRate(userPlaybackSpeed);
        await player!.play();
        setState(() {
          isPlaying = true;
          isInitialized = true;
          currentPlaybackSpeed = userPlaybackSpeed;
        });
      } else {
        setState(() {
          hasError = true;
          errorMessage = 'MediaKit is not supported on this platform.';
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = 'Failed to initialize player: $e';
      });
      debugPrint('Video player error: $e');
    }
  }

  // 优化字幕查找，使用二分查找算法提高性能
  int _findSubtitleIndexByPosition(Duration position) {
    if (subtitles.isEmpty) return -1;

    // 对于少量字幕，线性查找可能更快
    if (subtitles.length < 20) {
      for (int i = 0; i < subtitles.length; i++) {
        final subtitle = subtitles[i];
        if (position >= subtitle.start && position <= subtitle.end) {
          return i;
        }
      }
      return -1;
    }

    // 二分查找
    int low = 0;
    int high = subtitles.length - 1;

    while (low <= high) {
      int mid = (low + high) ~/ 2;
      final subtitle = subtitles[mid];

      if (position < subtitle.start) {
        high = mid - 1;
      } else if (position > subtitle.end) {
        low = mid + 1;
      } else {
        return mid; // 找到匹配的字幕
      }
    }

    return -1;
  }

  void _checkCurrentSubtitle(Duration position) {
    if (!enableSubtitleAudio || subtitles.isEmpty) return;

    // 如果当前正在播放音频且还未完成，阻止切换到新字幕
    if (isAudioPlaying && !isAudioCompleted) {
      // 音频播放中，不允许切换字幕
      return;
    }

    // 使用优化的二分查找方法查找当前时间点对应的字幕
    int nextSubtitleIndex = _findSubtitleIndexByPosition(position);

    // 如果找到新字幕，且与当前字幕不同
    if (nextSubtitleIndex != -1 && nextSubtitleIndex != currentSubtitleIndex) {
      // 检查是否是刚刚播放过的字幕
      if (nextSubtitleIndex == lastPlayedSubtitleIndex &&
          preventSubtitleRepeat) {
        return;
      }

      setState(() {
        currentSubtitleIndex = nextSubtitleIndex;
        preventSubtitleRepeat = true;
        lastPlayedSubtitleIndex = nextSubtitleIndex;
      });

      // 播放新字幕对应的音频
      _playSubtitleAudio(nextSubtitleIndex);
    }
    // 如果当前没有字幕，并且之前有字幕在显示
    else if (nextSubtitleIndex == -1 && currentSubtitleIndex != -1) {
      // 只有当音频已经播放完成时，才允许清除当前字幕
      if (isAudioCompleted) {
        setState(() {
          currentSubtitleIndex = -1;
          preventSubtitleRepeat = false;
        });
      }
    }
  }

  // 当用户手动跳转播放位置时调用
  void _onUserSeek(Duration position) {
    // 停止当前音频播放，强制重置状态
    if (audioPlayer != null && isAudioPlaying) {
      audioPlayer!.stop();
      setState(() {
        isAudioPlaying = false;
        isAudioCompleted = true;
        // 重置当前字幕索引，使系统可以重新检测当前位置的字幕
        currentSubtitleIndex = -1;
        preventSubtitleRepeat = false;
      });
    }

    // 恢复正常播放速度
    if (isAdjustingForAudio) {
      _restoreUserPlaybackSpeed();
    }

    // 立即检查新位置的字幕
    _checkCurrentSubtitle(position);
  }

  void _seekTo(Duration position) {
    if (player == null) return;
    player!.seek(position);

    // 处理用户跳转后的字幕和音频同步
    _onUserSeek(position);

    _onUserActivity();
  }

  void _seekBackward() {
    if (player == null) return;
    final currentPosition = player!.state.position;
    final newPosition = currentPosition - const Duration(seconds: 10);
    player!.seek(newPosition);

    // 处理用户跳转后的字幕和音频同步
    _onUserSeek(newPosition);

    _onUserActivity();
  }

  void _seekForward() {
    if (player == null) return;
    final currentPosition = player!.state.position;
    final newPosition = currentPosition + const Duration(seconds: 10);
    player!.seek(newPosition);

    // 处理用户跳转后的字幕和音频同步
    _onUserSeek(newPosition);

    _onUserActivity();
  }

  // 预加载字幕对应的音频文件
  Future<void> _preloadSubtitleAudio(int currentIndex) async {
    if (!enableSubtitleAudio || subtitles.isEmpty) return;

    // 预加载未来几条字幕的音频
    for (int i = currentIndex + 1;
        i < subtitles.length && i <= currentIndex + _preloadAheadCount;
        i++) {
      _preloadAudioFile(i);
    }
  }

  // 预加载指定索引的音频文件
  Future<void> _preloadAudioFile(int index) async {
    if (index < 0 ||
        index >= subtitles.length ||
        _preloadingAudioIds.contains(index)) {
      return;
    }

    try {
      final id = (index + 1).toString();
      final audioUrl = "$audioBaseUrl$id.mp3";

      // 标记为正在预加载
      _preloadingAudioIds.add(index);

      // 检查是否已缓存
      if (_audioCachePaths.containsKey(id)) {
        debugPrint('音频文件 $id 已预加载');
        return;
      }

      debugPrint('预加载音频文件: $audioUrl');

      // 下载音频文件
      final response = await http.get(Uri.parse(audioUrl));
            final String videoId = widget.videoId!;


      if (response.statusCode == 200) {
        // 获取临时目录
        final tempDir = await getTemporaryDirectory();
        final audioFile = File('${tempDir.path}/${videoId}_$id.mp3');

        // 写入文件
        await audioFile.writeAsBytes(response.bodyBytes);

        // 保存缓存路径
        _audioCachePaths[id] = audioFile.path;

        debugPrint('音频文件 $id 预加载完成: ${audioFile.path}');
      } else {
        debugPrint('预加载音频文件 $id 失败: HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('预加载音频文件错误: $e');
    } finally {
      // 从预加载列表中移除
      _preloadingAudioIds.remove(index);
    }
  }

  Future<void> _playSubtitleAudio(int index) async {
    if (!enableSubtitleAudio ||
        audioPlayer == null ||
        index >= subtitles.length) {
      return;
    }

    try {
      // 标记音频未完成
      setState(() {
        isAudioCompleted = false;
      });

      // 计算并设置最佳播放速度
      await _calculateAndSetOptimalPlaybackSpeed(index);

      // 获取音频文件ID
      final id = (index + 1).toString();
      String audioPath;

      // 检查是否已缓存
      // if (_audioCachePaths.containsKey(id)) {
      //   audioPath = _audioCachePaths[id]!;
      //   debugPrint('使用缓存的音频文件: $audioPath');
      // } else {
      //   // 未缓存，直接使用网络URL
        audioPath = "$audioBaseUrl$id.mp3";
      //   debugPrint('使用网络音频URL: $audioPath');

      //   // 同时触发预加载，以便下次使用
        _preloadAudioFile(index);
      // }

      // 停止当前正在播放的音频
      await audioPlayer!.stop();

      // 播放新的音频
      await audioPlayer!.open(Media(audioPath));

      // 设置音频播放速度 - 保持音频原始播放速度
      await audioPlayer!.play();

      // 更新字幕显示（确保视频位置与当前字幕匹配）
      final subtitle = subtitles[index];
      final currentPosition = player!.state.position;

      // 如果当前播放位置不在字幕时间范围内，调整到字幕开始时间
      if (currentPosition < subtitle.start || currentPosition > subtitle.end) {
        await player!.seek(subtitle.start);
        debugPrint('调整视频位置到字幕开始时间: ${subtitle.start.inSeconds}秒');
      }

      setState(() {
        isAudioPlaying = true;
      });

      // 预加载后续字幕的音频
      _preloadSubtitleAudio(index);
    } catch (e) {
      debugPrint('播放字幕音频出错: $e');
      // 出错时恢复播放速度
      _restoreUserPlaybackSpeed();
      setState(() {
        isAudioCompleted = true;
        isAudioPlaying = false;
      });
    }
  }

  Future<void> _calculateAndSetOptimalPlaybackSpeed(int subtitleIndex) async {
    if (!enableSubtitleAudio ||
        subtitleIndex >= subtitles.length ||
        player == null) return;

    try {
      final subtitle = subtitles[subtitleIndex];

      // 计算字幕持续时间
      final subtitleDuration = subtitle.end - subtitle.start;

      // 获取音频持续时间
      currentAudioDuration = await _getAudioDuration(subtitleIndex);

      if (currentAudioDuration == null ||
          currentAudioDuration!.inMilliseconds == 0) {
        debugPrint('无法获取音频时长，使用默认播放速度');
        return;
      }

      // 计算理想速度比例：字幕显示时间 / 音频播放时间
      // 如果比例 < 1，意味着音频比字幕时间长，需要减慢视频播放速度
      double idealRatio =
          subtitleDuration.inMilliseconds /
          currentAudioDuration!.inMilliseconds;

      // 限制最小速度为原速度的90%
      double minimumSpeed = userPlaybackSpeed * 0.9;
      double calculatedSpeed;

      // 如果理想比例小于1，需要减慢视频播放
      if (idealRatio < 1.0) {
        // 计算实际播放速度：用户设置的速度 * 理想比例
        calculatedSpeed = userPlaybackSpeed * idealRatio;
        // 确保不低于最小速度限制
        calculatedSpeed =
            calculatedSpeed < minimumSpeed ? minimumSpeed : calculatedSpeed;
      } else {
        // 如果字幕时长足够长，无需调整速度
        calculatedSpeed = userPlaybackSpeed;
      }

      // 应用新的播放速度
      await player!.setRate(calculatedSpeed);

      setState(() {
        isAdjustingForAudio = true;
        currentPlaybackSpeed = calculatedSpeed;
      });

      debugPrint(
        '调整播放速度: $calculatedSpeed (用户速度: $userPlaybackSpeed, 字幕时长: ${subtitleDuration.inMilliseconds}ms, 音频时长: ${currentAudioDuration!.inMilliseconds}ms, 比例: $idealRatio)',
      );
    } catch (e) {
      debugPrint('计算最佳播放速度错误: $e');
    }
  }

  Future<Duration?> _getAudioDuration(int index) async {
    try {
      final id = (index + 1).toString();
      final audioUrl = "$audioBaseUrl$id.mp3";

      final tempPlayer = Player();
      await tempPlayer.open(Media(audioUrl));

      int maxAttempts = 10;
      int attempts = 0;
      Duration? duration;

      while (attempts < maxAttempts) {
        duration = tempPlayer.state.duration;
        if (duration != null && duration.inMilliseconds > 0) {
          break;
        }
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }

      tempPlayer.dispose();

      debugPrint('音频$id时长: ${duration?.inMilliseconds}ms (尝试次数: $attempts)');
      return duration;
    } catch (e) {
      debugPrint('获取音频时长错误: $e');
      return null;
    }
  }

  void _onAudioCompleted() {
    setState(() {
      isAudioCompleted = true;
      isAudioPlaying = false;
    });

    // 恢复用户选择的播放速度
    if (isAdjustingForAudio) {
      _restoreUserPlaybackSpeed();
    }

    // 音频结束后，如果当前位置已经不在当前字幕范围内，立即更新字幕状态
    if (player != null) {
      final currentPosition = player!.state.position;
      if (currentSubtitleIndex >= 0 &&
          currentSubtitleIndex < subtitles.length) {
        final subtitle = subtitles[currentSubtitleIndex];
        if (currentPosition < subtitle.start ||
            currentPosition > subtitle.end) {
          _checkCurrentSubtitle(currentPosition);
        }
      }
    }

    debugPrint('音频播放完成，恢复播放速度: $userPlaybackSpeed');
  }

  Future<void> _restoreUserPlaybackSpeed() async {
    if (player != null && isAdjustingForAudio) {
      await player!.setRate(userPlaybackSpeed);
      setState(() {
        currentPlaybackSpeed = userPlaybackSpeed;
        isAdjustingForAudio = false;
      });
      debugPrint('已恢复用户设置的播放速度: $userPlaybackSpeed');
    }
  }

  Future<void> _setUserPlaybackSpeed(double speed) async {
    if (player != null) {
      // 记录用户设置的速度
      userPlaybackSpeed = speed;

      // 如果当前没有音频播放，或者禁用了字幕音频，则直接应用速度
      if (!isAudioPlaying || !enableSubtitleAudio) {
        await player!.setRate(speed);
        setState(() {
          currentPlaybackSpeed = speed;
        });
        debugPrint('已设置用户播放速度: $speed');
      } else {
        // 如果正在播放音频，当前不改变播放速度，等音频播放完成后恢复
        debugPrint('已记录用户播放速度: $speed (将在当前音频结束后应用)');
      }
    }
  }

  void _toggleSubtitleAudio() {
    setState(() {
      enableSubtitleAudio = !enableSubtitleAudio;
    });

    if (!enableSubtitleAudio) {
      // 关闭音频时，停止当前音频播放，恢复用户设置的播放速度
      if (audioPlayer != null && isAudioPlaying) {
        audioPlayer!.stop();
        setState(() {
          isAudioPlaying = false;
          isAudioCompleted = true;
        });
      }

      // 恢复用户设置的播放速度
      if (isAdjustingForAudio) {
        _restoreUserPlaybackSpeed();
      }
    }

    _onUserActivity();
  }

  @override
  void dispose() {
    _userActivityTimer?.cancel();

    try {
      if (audioPlayer != null) {
        audioPlayer!.stop();
        audioPlayer!.dispose();
        audioPlayer = null;
      }

      if (player != null) {
        player!.stop();
        player!.dispose();
        player = null;
      }

      controller = null;
    } catch (e) {
      debugPrint('Error disposing resources: $e');
    }

    super.dispose();
  }

  void _togglePlayPause() {
    if (player == null) return;

    if (isPlaying) {
      player!.pause();
      // 同时暂停音频播放
      if (audioPlayer != null && isAudioPlaying) {
        audioPlayer!.pause();
      }
    } else {
      player!.play();
      // 如果有音频正在播放，恢复音频播放
      if (audioPlayer != null && isAudioPlaying && !isAudioCompleted) {
        audioPlayer!.play();
      }
    }
    setState(() {
      isPlaying = !isPlaying;
    });

    _onUserActivity();
  }

  void _toggleFullScreen() {
    setState(() {
      isFullScreen = !isFullScreen;
    });

    _onUserActivity();
  }

  void _toggleSubtitles() {
    if (player != null) {
      setState(() {
        isSubtitlesEnabled = !isSubtitlesEnabled;
      });

      if (isSubtitlesEnabled) {
        player!.setSubtitleTrack(
          SubtitleTrack.uri(subtitleUrl, title: "zh-cn", language: 'zh'),
        );
      } else {
        player!.setSubtitleTrack(SubtitleTrack.no());
      }
    }

    _onUserActivity();
  }

  // 构建更美观的控制按钮
  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    double iconSize = 24.0,
    String? text,
    Color? iconColor,
    bool isActive = true,
  }) {
    final color = iconColor ?? (isActive ? Colors.white : Colors.white.withOpacity(0.7));
    
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.2),
            ),
            child: Center(
              child: text != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: color, size: iconSize * 0.7),
                      Text(
                        text,
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  )
                : Icon(icon, color: color, size: iconSize),
            ),
          ),
        ),
      ),
    );
  }

  // 实现带动画效果的播放/暂停按钮
  Widget _buildPlayButton() {
    return Center(
      child: AnimatedOpacity(
        opacity: _isUserActive || !isPlaying ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: GestureDetector(
          onTap: _togglePlayPause,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                key: ValueKey<bool>(isPlaying),
                color: Colors.white,
                size: 50,
              ),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
            ),
          ),
        ),
      ),
    );
  }

  // 更现代的快进快退动画效果
  Widget _buildDragFeedback() {
    if (!_isDragging || _seekAmount == 0) {
      return const SizedBox.shrink();
    }

    final isForward = _seekAmount > 0;
    final absAmount = _seekAmount.abs();
    
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isForward ? Colors.blue.withOpacity(0.7) : Colors.red.withOpacity(0.7),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (isForward ? Colors.blue : Colors.red).withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isForward ? Icons.fast_forward : Icons.fast_rewind,
              color: isForward ? Colors.blue : Colors.red,
              size: 36,
            ),
            const SizedBox(width: 16),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isForward ? '快进' : '快退',
                  style: TextStyle(
                    color: isForward ? Colors.blue : Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$absAmount 秒',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 处理设置面板的子菜单选择
  void _handleSubmenuSelected(int index) {
    setState(() {
      if (index == -1) {
        // 返回主菜单
        _currentSubmenuIndex = null;
      } else {
        _currentSubmenuIndex = index;
      }
    });
  }

  // 处理稳定音量设置变更
  void _handleStableVolumeChanged(bool value) {
    setState(() {
      _stableVolume = value;
    });
    // 这里可以添加实际的音量稳定逻辑
  }

  // 处理注释设置变更
  void _handleAnnotationsChanged(bool value) {
    setState(() {
      _showAnnotations = value;
    });
    // 这里可以添加显示/隐藏注释的逻辑
  }

  // 处理字幕模式设置变更
  void _handleSubtitleModeChanged(String mode) {
    setState(() {
      _currentSubtitleModeText = mode;

      // 根据文本设置实际的字幕模式
      if (mode == '关闭') {
        _subtitleMode = SubtitleMode.off;
      } else if (mode == '字幕 (1)') {
        _subtitleMode = SubtitleMode.chinese;
      } else if (mode == '自动翻译') {
        _subtitleMode = SubtitleMode.bilingual;
      }
    });

    // 关闭设置面板
    setState(() {
      _isSettingsPanelVisible = false;
    });
  }

  // 处理休眠定时器设置变更
  void _handleSleepTimerChanged(String timer) {
    setState(() {
      _currentSleepTimer = timer;
    });

    // 这里可以添加设置休眠定时器的逻辑
  }

  // 处理播放速度设置变更
  void _handlePlaybackSpeedChanged(String speed) {
    setState(() {
      _currentPlaybackSpeed = speed;

      // 根据文本设置实际的播放速度
      double newSpeed = 1.0;
      if (speed == '0.25x') newSpeed = 0.25;
      else if (speed == '0.5x') newSpeed = 0.5;
      else if (speed == '0.75x') newSpeed = 0.75;
      else if (speed == '正常') newSpeed = 1.0;
      else if (speed == '1.25x') newSpeed = 1.25;
      else if (speed == '1.5x') newSpeed = 1.5;
      else if (speed == '1.75x') newSpeed = 1.75;
      else if (speed == '2x') newSpeed = 2.0;

      _setUserPlaybackSpeed(newSpeed);
    });

    // 关闭设置面板
    setState(() {
      _isSettingsPanelVisible = false;
    });
  }

  // 处理画质设置变更
  void _handleQualityChanged(String quality) {
    setState(() {
      _currentQuality = quality;
    });

    // 这里可以添加设置视频画质的逻辑

    // 关闭设置面板
    setState(() {
      _isSettingsPanelVisible = false;
    });
  }

  // 优化后的视频进度条实现
  Widget _buildProgressBar(
    Duration position,
    Duration duration,
    double progress,
  ) {
    return Column(
      children: [
        // 进度条
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14.0),
            trackShape: const RoundedRectSliderTrackShape(),
            activeTrackColor: Theme.of(context).primaryColor,
            inactiveTrackColor: Colors.grey.shade600,
            thumbColor: Colors.white,
            overlayColor: Theme.of(context).primaryColor.withOpacity(0.3),
          ),
          child: Slider(
            value: progress,
            min: 0.0,
            max: 1.0,
            onChangeStart: (value) {
              setState(() {
                _isDragging = true;
              });

              // 如果视频正在播放，暂时暂停
              if (isPlaying && player != null) {
                player!.pause();
              }
            },
            onChanged: (value) {
              // 显示实时反馈
              final newPosition = Duration(
                milliseconds: (value * duration.inMilliseconds).round(),
              );
              setState(() {
                // 仅更新显示位置，不实际跳转
                player!.seek(newPosition);
              });
              _onUserActivity();
            },
            onChangeEnd: (value) {
              final newPosition = Duration(
                milliseconds: (value * duration.inMilliseconds).round(),
              );
              
              _seekTo(newPosition);
              
              setState(() {
                _isDragging = false;
              });
              
              // 如果之前是播放状态，恢复播放
              if (isPlaying && player != null) {
                player!.play();
              }
            },
          ),
        ),
        
        const SizedBox(height: 4),
        
        // 时间显示
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(position),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              Text(
                _formatDuration(duration),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 构建字幕模式选择菜单
  Widget _buildSubtitleModeMenu() {
    return IconButton(
      icon: Icon(
        Icons.subtitles,
        // Change icon color based on subtitle mode to provide visual feedback
        color: _subtitleMode == SubtitleMode.off ? Colors.grey : Colors.white,
      ),
      tooltip: _subtitleMode == SubtitleMode.off ? '开启字幕' : '关闭字幕',
      onPressed: () {
        setState(() {
          // Toggle between off and chinese modes
          _subtitleMode = _subtitleMode == SubtitleMode.off
              ? SubtitleMode.chinese
              : SubtitleMode.off;

          // Update subtitle mode text in settings panel
          _currentSubtitleModeText =
              _subtitleMode == SubtitleMode.off ? '关闭' : '字幕 (1)';
        });
      },
    );
  }

  // 构建设置按钮
  Widget _buildSettingsButton() {
    return IconButton(
      icon: const Icon(Icons.settings, color: Colors.white),
      tooltip: '设置',
      onPressed: () {
        setState(() {
          _isSettingsPanelVisible = !_isSettingsPanelVisible;
          _currentSubmenuIndex = null; // 重置子菜单索引
        });
      },
    );
  }

  Widget _buildDebugInfo() {
    // 仅在开发环境启用
    if (!isDebugMode) return const SizedBox.shrink();

    return Positioned(
      top: 50,
      right: 10,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '字幕索引: $currentSubtitleIndex/${subtitles.length}',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            Text(
              '音频播放: ${isAudioPlaying ? "是" : "否"}',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            Text(
              '音频完成: ${isAudioCompleted ? "是" : "否"}',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            Text(
              '视频速度: ${currentPlaybackSpeed.toStringAsFixed(2)}x',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            Text(
              '调速状态: ${isAdjustingForAudio ? "是" : "否"}',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  // 构建当前字幕显示
  Widget _buildCurrentSubtitle() {
    if (currentSubtitleIndex == -1 ||
        currentSubtitleIndex >= subtitles.length ||
        _subtitleMode == SubtitleMode.off) {
      return const SizedBox.shrink();
    }

    final subtitle = subtitles[currentSubtitleIndex];
    String? originalText;
    String? translatedText;

    // 从字幕文本中提取原文和翻译（假设格式为"原文\n[翻译]"）
    final parts = subtitle.data.split('\n');
    if (parts.isNotEmpty) {
      originalText = parts[0];

      // 查找翻译文本（通常在第二行，可能带有[]标记）
      if (parts.length > 1) {
        translatedText = parts.sublist(1).join('\n');
        // 移除可能的标记，如 [1]、[翻译] 等
        translatedText =
            translatedText.replaceAll(RegExp(r'\[\d+\]|\[.*?\]'), '').trim();
      }
    }

    // 根据字幕模式决定显示内容
    Widget subtitleWidget;
    switch (_subtitleMode) {
      case SubtitleMode.chinese:
        // 如果有翻译文本则显示翻译，否则显示原文
        subtitleWidget = Text(
          translatedText != null && translatedText.isNotEmpty
              ? translatedText
              : originalText ?? '',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            shadows: [
              Shadow(
                  color: Colors.black,
                  offset: Offset(1, 1),
                  blurRadius: 2),
            ],
          ),
          textAlign: TextAlign.center,
        );
        break;

      case SubtitleMode.original:
        // 只显示原文
        subtitleWidget = Text(
          originalText ?? '',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            shadows: [
              Shadow(
                  color: Colors.black,
                  offset: Offset(1, 1),
                  blurRadius: 2),
            ],
          ),
          textAlign: TextAlign.center,
        );
        break;

      case SubtitleMode.bilingual:
        // 显示双语字幕
        subtitleWidget = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (originalText != null && originalText.isNotEmpty)
              Text(
                originalText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  shadows: [
                    Shadow(
                        color: Colors.black,
                        offset: Offset(1, 1),
                        blurRadius: 2),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            if (originalText != null &&
                translatedText != null &&
                translatedText.isNotEmpty)
              const SizedBox(height: 2), // 减小垂直间距
            if (translatedText != null && translatedText.isNotEmpty)
              Text(
                translatedText,
                style: const TextStyle(
                  color: Colors.yellow,
                  fontSize: 16,
                  shadows: [
                    Shadow(
                        color: Colors.black,
                        offset: Offset(1, 1),
                        blurRadius: 2),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
          ],
        );
        break;

      default:
        return const SizedBox.shrink();
    }

    // 使用更紧凑的容器，减小边距和内边距，降低背景不透明度
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        margin: const EdgeInsets.only(bottom: 65, left: 0, right: 0),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: subtitleWidget,
      ),
    );
  }

  // 循环切换字幕显示模式
  void _toggleSubtitleMode() {
    setState(() {
      switch (_subtitleMode) {
        case SubtitleMode.off:
          _subtitleMode = SubtitleMode.chinese;
          _currentSubtitleModeText = '字幕 (1)';
          break;
        case SubtitleMode.chinese:
          _subtitleMode = SubtitleMode.original;
          _currentSubtitleModeText = '原文';
          break;
        case SubtitleMode.original:
          _subtitleMode = SubtitleMode.bilingual;
          _currentSubtitleModeText = '双语';
          break;
        case SubtitleMode.bilingual:
          _subtitleMode = SubtitleMode.off;
          _currentSubtitleModeText = '关闭';
          break;
      }
    });
    _onUserActivity();
  }

  // 优化后的控制栏布局
  Widget _buildControlBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 进度条
          StreamBuilder<Duration>(
            stream: player?.stream.position,
            initialData: Duration.zero,
            builder: (context, posSnapshot) {
              final position = posSnapshot.data ?? Duration.zero;
              
              return StreamBuilder<Duration>(
                stream: player?.stream.duration,
                initialData: Duration.zero,
                builder: (context, durSnapshot) {
                  final duration = durSnapshot.data ?? Duration.zero;
                  
                  if (duration.inMilliseconds <= 0) {
                    return _buildProgressBar(position, Duration.zero, 0);
                  }
                  
                  // 计算进度比例
                  final progress = position.inMilliseconds / duration.inMilliseconds;
                  final safeProgress = progress.clamp(0.0, 1.0);
                  
                  return _buildProgressBar(position, duration, safeProgress);
                },
              );
            },
          ),
          
          const SizedBox(height: 8),
          
          // 控制按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildControlButton(
                icon: Icons.replay_10,
                tooltip: '后退10秒',
                onPressed: _seekBackward,
                iconColor: Colors.white,
              ),
              _buildControlButton(
                icon: Icons.skip_previous,
                tooltip: '上一个',
                onPressed: () {
                  // 实现跳转到上一个章节或关键点
                },
                iconColor: Colors.white,
              ),
              _buildControlButton(
                icon: isPlaying ? Icons.pause : Icons.play_arrow,
                tooltip: isPlaying ? '暂停' : '播放',
                onPressed: _togglePlayPause,
                iconSize: 40,
                iconColor: Colors.white,
              ),
              _buildControlButton(
                icon: Icons.skip_next,
                tooltip: '下一个',
                onPressed: () {
                  // 实现跳转到下一个章节或关键点
                },
                iconColor: Colors.white,
              ),
              _buildControlButton(
                icon: Icons.forward_10,
                tooltip: '前进10秒',
                onPressed: _seekForward,
                iconColor: Colors.white,
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // 额外控制按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildControlButton(
                    icon: Icons.speed,
                    text: '${currentPlaybackSpeed.toStringAsFixed(1)}x',
                    tooltip: '播放速度',
                    onPressed: () {
                      // 循环切换播放速度
                      double newSpeed;
                      if (userPlaybackSpeed >= 2.0) {
                        newSpeed = 0.5;
                      } else {
                        newSpeed = userPlaybackSpeed + 0.25;
                      }
                      _setUserPlaybackSpeed(newSpeed);
                    },
                    iconSize: 20,
                    iconColor: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  _buildControlButton(
                    icon: isSubtitlesEnabled ? Icons.subtitles : Icons.subtitles_off,
                    tooltip: isSubtitlesEnabled ? '关闭字幕' : '打开字幕',
                    onPressed: _toggleSubtitles,
                    iconSize: 20,
                    iconColor: Colors.white,
                  ),
                ],
              ),
              Row(
                children: [
                  _buildControlButton(
                    icon: enableSubtitleAudio ? Icons.volume_up : Icons.volume_off,
                    tooltip: enableSubtitleAudio ? '关闭字幕音频' : '打开字幕音频',
                    onPressed: _toggleSubtitleAudio,
                    iconSize: 20,
                    iconColor: enableSubtitleAudio ? Theme.of(context).primaryColor : Colors.white,
                  ),
                  const SizedBox(width: 8),
                  _buildControlButton(
                    icon: isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                    tooltip: isFullScreen ? '退出全屏' : '全屏',
                    onPressed: _toggleFullScreen,
                    iconSize: 20,
                    iconColor: Colors.white,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 更新后的手势控制功能
  Widget _buildGestureDetector() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        // 单击切换控制栏显示状态
        _onUserActivity();
      },
      onDoubleTap: _togglePlayPause,
      onHorizontalDragStart: (details) {
        if (player == null) return;
        setState(() {
          _isDragging = true;
          _dragStartPos = details.localPosition.dx;
          _dragStartTime = player!.state.position;
          _seekAmount = 0;
        });
        _onUserActivity();
      },
      onHorizontalDragUpdate: (details) {
        if (!_isDragging || _dragStartTime == null) return;

        // 计算拖动距离相对于屏幕宽度的比例
        final screenWidth = MediaQuery.of(context).size.width;
        final dragDistance = details.localPosition.dx - _dragStartPos;
        final dragPercent = dragDistance / (screenWidth / 3); // 增加灵敏度

        // 计算拖动对应的秒数，最大30秒
        final newSeekAmount = (dragPercent * 30).round();

        if (newSeekAmount != _seekAmount) {
          setState(() {
            _seekAmount = newSeekAmount;
          });
          _onUserActivity();
        }
      },
      onHorizontalDragEnd: (details) {
        if (!_isDragging || _dragStartTime == null || player == null) return;

        // 应用拖动产生的快进/后退效果
        if (_seekAmount != 0) {
          final newPosition = _dragStartTime! + Duration(seconds: _seekAmount);
          _seekTo(newPosition);
        }

        setState(() {
          _isDragging = false;
          _dragStartTime = null;
          _seekAmount = 0;
        });
      },
      // 添加垂直滑动控制音量
      onVerticalDragStart: (details) {
        // 这里可以实现音量控制的功能
        _onUserActivity();
      },
      onVerticalDragUpdate: (details) {
        // 实现音量控制逻辑
      },
      onVerticalDragEnd: (details) {
        // 完成音量调整
      },
      child: Container(
        color: Colors.transparent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Video Player'),
          elevation: 0,
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 16),
              Text(
                'Error: $errorMessage',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    hasError = false;
                    isInitialized = false;
                  });
                  _loadFilesFromVideoId();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (!isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            const WindowTitleBar(
              title: "",
            ),
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    strokeWidth: 2.0,
                  ),
                  SizedBox(height: 20),
                  Text('加载视频中...', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand, // 确保Stack占满整个屏幕
        children: [
          // 视频播放区域 - 放在最底层
          controller != null
              ? Video(
                  controller: controller!,
                  controls: NoVideoControls,
                  fill: Colors.black,
                  // 确保视频填充整个屏幕
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                )
              : const Center(
                  child: Text(
                    'Video player not available',
                    style: TextStyle(color: Colors.white),
                  ),
                ),

          // 手势检测层 - 在视频上方，处理播放控制手势
          Positioned.fill(
            child: _buildGestureDetector(),
          ),

          // 加载指示器
          if (_isBuffering)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),

          // 拖动反馈显示
          _buildDragFeedback(),

          // 播放/暂停按钮
          _buildPlayButton(),

          // 顶部控制栏 (包含窗口控制按钮和标题)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 窗口标题栏 - 负责窗口拖动
                const WindowTitleBar(
                  title: "",
                ),

                // 视频标题和控制按钮
                AnimatedOpacity(
                  opacity: _isUserActive ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    child: Row(
                      children: [
                        // 返回按钮
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back,
                              color: Colors.white),
                        ),

                        // 视频标题
                        Expanded(
                          child: Text(
                            widget.videoId != null ? widget.videoId! : '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // 字幕和设置按钮
                        _buildSubtitleModeMenu(),
                        _buildSettingsButton(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 底部控制面板
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: _isUserActive || !isPlaying ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: _buildControlBar(),
            ),
          ),

          // 设置面板
          if (_isSettingsPanelVisible)
            Positioned(
              right: 0,
              top: 40, // 避免遮挡标题栏
              height: 410,
              width: 250,
              child: SettingsPanel(
                currentSubmenuIndex: _currentSubmenuIndex,
                onSubmenuSelected: _handleSubmenuSelected,
                onClose: () {
                  setState(() {
                    _isSettingsPanelVisible = false;
                  });
                  _onUserActivity();
                },
                stableVolume: _stableVolume,
                showAnnotations: _showAnnotations,
                onStableVolumeChanged: _handleStableVolumeChanged,
                onAnnotationsChanged: _handleAnnotationsChanged,
                currentSubtitleMode: _currentSubtitleModeText,
                onSubtitleModeChanged: _handleSubtitleModeChanged,
                currentSleepTimer: _currentSleepTimer,
                onSleepTimerChanged: _handleSleepTimerChanged,
                currentPlaybackSpeed: _currentPlaybackSpeed,
                onPlaybackSpeedChanged: _handlePlaybackSpeedChanged,
                currentQuality: _currentQuality,
                onQualityChanged: _handleQualityChanged,
              ),
            ),

          // 调试信息
          if (isDebugMode) _buildDebugInfo(),

          // 当前字幕显示
          _buildCurrentSubtitle(),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return hours == '00' ? '$minutes:$seconds' : '$hours:$minutes:$seconds';
  }
}
