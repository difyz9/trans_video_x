enum TaskStatus {
  pending,
  downloading,
  extractingFrames,
  extractingAudio,
  uploadingAudio,
  uploadingFrames,
  completed,
  error
}

class VideoTaskStatus {
  final String urlId;
  final TaskStatus status;
  final String? message;
  final DateTime lastUpdated;

  VideoTaskStatus({
    required this.urlId,
    required this.status,
    this.message,
    DateTime? lastUpdated,
  }) : this.lastUpdated = lastUpdated ?? DateTime.now();

  VideoTaskStatus copyWith({
    String? urlId,
    TaskStatus? status,
    String? message,
  }) {
    return VideoTaskStatus(
      urlId: urlId ?? this.urlId,
      status: status ?? this.status,
      message: message ?? this.message,
      lastUpdated: DateTime.now(),
    );
  }
}
