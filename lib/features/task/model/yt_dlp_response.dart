import 'package:flutter/material.dart';
import 'package:trans_video_x/features/task/model/yt_dlp_video.dart';

enum YtDlpStatus {
  success,
  error,
  warning,
  info,
}

class YtDlpResponse {
  final YtDlpStatus? status;
  final String message;
  final YtDlpVideo? video;
  final bool success;

  YtDlpResponse({
    this.status,
    required this.message,
    this.video,
    this.success = false,
  });

  Color get _snackbarColor {
    switch (status) {
      case YtDlpStatus.success:
        return Colors.green;
      case YtDlpStatus.error:
        return Colors.red;
      case YtDlpStatus.warning:
        return Colors.orange;
      case YtDlpStatus.info:
        return Colors.blue;
      default:
        return this.success ? Colors.green : Colors.grey;
    }
  }

  SnackBar _snackbar(BuildContext context) {
    return SnackBar(
      duration: const Duration(seconds: 5),
      content: Text(message),
      backgroundColor: _snackbarColor,
      behavior: SnackBarBehavior.floating,
    );
  }

  void showSnackbar(BuildContext context) {
    if (message.isNotEmpty && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(_snackbar(context));
    }
  }
}
