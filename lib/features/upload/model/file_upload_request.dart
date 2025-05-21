class FileUploadRequest {
  final List<String> filePaths;
  final String sourceLanguage;
  final String targetLanguage;
  final String provider;
  final String voice;

  FileUploadRequest({
    required this.filePaths,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.provider,
    required this.voice,
  });

  factory FileUploadRequest.fromJson(Map<String, dynamic> json) {
    return FileUploadRequest(
      filePaths: List<String>.from(json['filePaths']),
      sourceLanguage: json['sourceLanguage'],
      targetLanguage: json['targetLanguage'],
      provider: json['provider'],
      voice: json['voice'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'filePaths': filePaths,
      'sourceLanguage': sourceLanguage,
      'targetLanguage': targetLanguage,
      'provider': provider,
      'voice': voice,
    };
  }
}

class FileUploadResponse {
  final String taskId;
  final int fileCount;
  final String message;
  final bool success;

  FileUploadResponse({
    required this.taskId,
    required this.fileCount,
    required this.message,
    required this.success,
  });

  factory FileUploadResponse.fromJson(Map<String, dynamic> json) {
    return FileUploadResponse(
      taskId: json['task_id'],
      fileCount: json['file_count'],
      message: json['message'],
      success: json['success'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'task_id': taskId,
      'file_count': fileCount,
      'message': message,
      'success': success,
    };
  }
}

// 定义上传状态
enum FileUploadStatus {
  initial,
  loading,
  success,
  error,
}

// 定义上传状态类
class FileUploadState {
  final FileUploadStatus status;
  final List<Map<String, dynamic>> fileInfoList;
  final FileUploadResponse? response;
  final String? errorMessage;

  FileUploadState({
    this.status = FileUploadStatus.initial,
    this.fileInfoList = const [],
    this.response,
    this.errorMessage,
  });

  FileUploadState copyWith({
    FileUploadStatus? status,
    List<Map<String, dynamic>>? fileInfoList,
    FileUploadResponse? response,
    String? errorMessage,
  }) {
    return FileUploadState(
      status: status ?? this.status,
      fileInfoList: fileInfoList ?? this.fileInfoList,
      response: response ?? this.response,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
