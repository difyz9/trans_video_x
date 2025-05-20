import 'dart:io';
import 'package:path/path.dart' as p;

class TaskStateManager {
  // Initial Configuration Parameters
  final String videoUrl;
  final String projectRoot; // Added from Python
  final String videoId;
  final String taskId; // Added from Python

  final String savePath = "temp/"; // Default save path - consider if still needed or replaced by projectRoot logic
  final String videoFormat = "mp4"; // Default video format
  final String audioFormat = "mp3"; // Default audio format

  // Dynamic State Parameters (evolve during processing)
  String? processedVideoPath; // This might be equivalent to outVideoPath or translateMp4
  String? extractedFramesPath;
  List<String>? extractedImageFiles;
  String? extractedAudioPath; // This might be equivalent to originalMp3
  String? extractedAudioFile;

  // Path properties from Python
  String currentDir;
  String? audioDir;
  String inputVideoPath;
  String? outVideoPath;
  String? translateMp4;
  String originalMp3;
  String? originalSrt;
  String? originalVtt;
  String? translateSrt;
  String? translateTxt;
  String? translateVtt;
  String imageCover;
  String? upVideoPath;
  String? videoCosUrl; // Note: Python version depends on 'settings' and 'video.cosKey'
  String? mindmapJson;
  String? translateMd;
  String? okFile;

  
  Map<String, dynamic> cache = {};

  // Error State
  bool hasError = false;
  String? errorMessage;
  dynamic errorDetails;

  TaskStateManager({
    required this.videoUrl,
    required this.projectRoot,

    // String? initialVideoCosUrl, // Optional: if you want to set it externally
  })  : videoId = _extractVideoId(videoUrl),
        currentDir = p.join(projectRoot, _extractVideoId(videoUrl)),
        inputVideoPath = p.join(projectRoot,_extractVideoId(videoUrl) ),
        originalMp3 = p.join(projectRoot, "${_extractVideoId(videoUrl)}.mp3"),
        imageCover = p.join(projectRoot, "cover.jpg"),
        taskId = DateTime.now().millisecondsSinceEpoch.toString() {
    // this.videoCosUrl = initialVideoCosUrl; // Example if passed
    // Or, if you have a Dart equivalent for settings.tx_cos_url and video.cosKey:
    // this.videoCosUrl = video != null ? '${YourDartSettings.txCosUrl}/${video.cosKey}' : null;
    _setupPaths();
  }

  static String _extractVideoId(String url) {
    final RegExp regExp = RegExp(
      r"(?:v=|\/)([0-9A-Za-z_-]{11})",
      caseSensitive: false,
      multiLine: false,
    );
    final Match? match = regExp.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      return match.group(1)!;
    }
    throw ArgumentError("Invalid YouTube URL: $url");
  }

  void _setupPaths() {
    if (videoId.isEmpty) return; // Or handle error

    // currentDir = p.join(projectRoot, videoId);

    // Ensure directories exist
    Directory(currentDir).createSync(recursive: true);
    Directory(p.join(currentDir, 'audio')).createSync(recursive: true);

    audioDir = p.join(currentDir, "audio");
    inputVideoPath = p.join(currentDir, "$videoId.mp4");
    outVideoPath = p.join(currentDir, "${videoId}_trans.mp4");
    translateMp4 = p.join(currentDir, "${videoId}_trans.mp4");
    originalMp3 = p.join(currentDir, "$videoId.mp3"); // Python used audio_dir here, but for consistency with video files, current_dir is used. Adjust if needed.
    // originalMp3 = p.join(audioDir!, "$videoId.mp3"); // Alternative based on Python structure
    originalSrt = p.join(currentDir, "en.srt");
    translateTxt = p.join(currentDir, "zh.txt");
    mindmapJson = p.join(currentDir, "$videoId.json");
    translateMd = p.join(currentDir, "$videoId.md");
    originalVtt = p.join(currentDir, "en.vtt");
    translateSrt = p.join(currentDir, "zh.srt");
    translateVtt = p.join(currentDir, "zh.vtt");
    imageCover = p.join(currentDir, "cover.jpg");
    okFile = p.join(currentDir, "ok");
    upVideoPath = inputVideoPath; // Default as per Python
  }

  String getRelativePath(String fullPath) {
    if (currentDir == null) {
      throw StateError("Paths not set up, currentDir is null.");
    }
    return p.relative(fullPath, from: currentDir!);
  }

  void setError(String message, [dynamic details]) {
    hasError = true;
    errorMessage = message;
    errorDetails = details;
    print("ERROR SET: $message - Details: $details");
  }

  void clearError() {
    hasError = false;
    errorMessage = null;
    errorDetails = null;
  }

  @override
  String toString() {
    return '''
TaskStateManager:
  Config:
    Video URL: $videoUrl
    Project Root: $projectRoot
    Video ID: $videoId
    Task ID: $taskId

  Paths:
    Current Dir: $currentDir
    Audio Dir: $audioDir
    Input Video Path: $inputVideoPath
    Output Video Path (Translated): $outVideoPath 
    Original MP3: $originalMp3
    Cover Image: $imageCover
    ... (add other paths as needed for debugging)

  State:
    Processed Video Path: $processedVideoPath 
    Extracted Frames Path: $extractedFramesPath
    Extracted Image Files: ${extractedImageFiles?.join(', ') ?? 'N/A'}
    Extracted Audio Path: $extractedAudioPath
    Extracted Audio File: $extractedAudioFile
    
  Error State:
    Has Error: $hasError
    Error Message: $errorMessage
    Error Details: $errorDetails
''';
  }
}