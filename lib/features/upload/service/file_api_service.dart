import 'dart:io';
import 'package:dio/dio.dart';

import 'package:trans_video_x/features/upload/model/file_upload_request.dart';
import 'package:trans_video_x/core/constants/app_constants.dart';
import 'package:path/path.dart' as path;


class FileApiService {
  final Dio dio;
  final String baseUrl;

  FileApiService(this.dio, {this.baseUrl = "${AppConstants.baseUrl}"});

  Future<FileUploadResponse> uploadFiles(FileUploadRequest request) async {
    try {
      // 创建 FormData 对象
      final formData = FormData();
      
      // 添加文本字段
      formData.fields.add(MapEntry('sourceLanguage', request.sourceLanguage));
      formData.fields.add(MapEntry('targetLanguage', request.targetLanguage));
      formData.fields.add(MapEntry('provider', request.provider));
      formData.fields.add(MapEntry('voice', request.voice));
      
      // 添加多个文件
      for (int i = 0; i < request.filePaths.length; i++) {
        final filePath = request.filePaths[i];
        final fileName = path.basename(filePath);
        
        // 创建 MultipartFile
        final multipartFile = await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        );
        
        // 添加到 FormData，使用 'files' 作为键名
        formData.files.add(MapEntry('files', multipartFile));
      }
      
      // 发送请求
      final response = await dio.post(
        "${baseUrl}/api/v1/upload/files",
        data: formData,
      );
      
      return FileUploadResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to upload files: $e');
    }
  }
}
