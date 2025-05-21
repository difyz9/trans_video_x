import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trans_video_x/features/upload/model/file_upload_request.dart';
import 'package:trans_video_x/features/upload/service/file_api_service.dart';
import 'package:trans_video_x/core/api/dio_provider.dart';

// 提供FileApiService实例的Provider


final fileApiServiceProvider = Provider<FileApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return FileApiService(dio);
});

// 文件上传状态的Provider
final fileUploadNotifierProvider = StateNotifierProvider<FileUploadNotifier, FileUploadState>((ref) {
  return FileUploadNotifier(ref.read(fileApiServiceProvider));
});

class FileUploadNotifier extends StateNotifier<FileUploadState> {
  final FileApiService _apiService;
  
  FileUploadNotifier(this._apiService) : super(FileUploadState());

  // 设置文件列表
  void setFileInfoList(List<Map<String, dynamic>> fileInfoList) {
    state = state.copyWith(fileInfoList: fileInfoList);
  }

  // 添加文件到列表
  void addFileInfo(Map<String, dynamic> fileInfo) {
    state = state.copyWith(fileInfoList: [...state.fileInfoList, fileInfo]);
  }

  // 从列表中删除文件
  void removeFileInfo(int index) {
    final newList = List<Map<String, dynamic>>.from(state.fileInfoList);
    newList.removeAt(index);
    state = state.copyWith(fileInfoList: newList);
  }

  // 清空文件列表
  void clearFileInfoList() {
    state = state.copyWith(fileInfoList: []);
  }

  // 上传文件
  Future<void> uploadFiles({
    required List<String> filePaths,
    required String sourceLanguage,
    required String targetLanguage,
    required String provider,
    required String voice,
  }) async {
    // 设置状态为加载中
    state = state.copyWith(status: FileUploadStatus.loading, errorMessage: null);

    try {
      // 创建请求对象
      final request = FileUploadRequest(
        filePaths: filePaths,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        provider: provider,
        voice: voice,
      );

      // 调用API上传文件
      final response = await _apiService.uploadFiles(request);

      // 更新状态为成功
      state = state.copyWith(
        status: FileUploadStatus.success,
        response: response,
      );
    } catch (e) {
      // 更新状态为错误
      state = state.copyWith(
        status: FileUploadStatus.error,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }
}
