import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trans_video_x/core/cos/models/bucket_model.dart';
import 'package:trans_video_x/core/cos/models/object_item.dart';
import 'package:trans_video_x/core/cos/services/cos_service.dart';

// Config providers
final currentBucketProvider = StateProvider<String?>((ref) => CosService.currentBucketName);
final currentRegionProvider = StateProvider<String?>((ref) => CosService.currentRegion);

// Bucket providers
final bucketsProvider = FutureProvider<List<BucketModel>>((ref) async {
  final cosBuckets = await CosService.listAllBuckets();
  return cosBuckets.map((bucket) => BucketModel.fromCOSBucket(bucket)).toList();
});

// Prefix for object listing
final currentPrefixProvider = StateProvider<String>((ref) => '');

// Objects provider
final objectsProvider = FutureProvider<List<ObjectItemModel>>((ref) async {
  final currentBucket = ref.watch(currentBucketProvider);
  final currentPrefix = ref.watch(currentPrefixProvider);
  
  if (currentBucket == null) return [];
  
  try {
    // Get objects with the current prefix
    final result = await CosService.listObjects(
      prefix: currentPrefix,
      delimiter: '/',
    );
    
    final List<ObjectItemModel> objects = [];
    
    // Parse common prefixes (directories)
    if (result.commonPrefixes != null) {
      for (var prefix in result.commonPrefixes) {
        final prefixObj = ObjectItemModel.fromCOSCommonPrefix(prefix);
        
        // Skip if the directory is the same as the current prefix
        // This prevents a directory from showing up in its own listing
        if (prefixObj.key == currentPrefix) continue;
        
        objects.add(prefixObj);
      }
    }
    
    // Parse objects (files)
    if (result.contents != null) {
      for (var item in result.contents) {
        final objectItem = ObjectItemModel.fromCOSObject(item);
        
        // Skip if it's the current directory marker (often a 0-byte object with the same name as the prefix)
        if (objectItem.key == currentPrefix) continue;
        
        // Skip hidden directory markers (objects ending with slash that represent folders)
        if (objectItem.isDirectory && objectItem.key == currentPrefix) continue;
        
        objects.add(objectItem);
      }
    }
    
    return objects;
  } catch (e) {
    // Extract only the error message
    throw Exception(extractErrorMessage(e));
  }
});

// COS Service操作的状态提供者
class CosOperationState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;
  final dynamic result;

  const CosOperationState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
    this.result,
  });

  CosOperationState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
    dynamic result,
  }) {
    return CosOperationState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSuccess: isSuccess ?? this.isSuccess,
      result: result ?? this.result,
    );
  }

  factory CosOperationState.initial() => const CosOperationState();
  factory CosOperationState.loading() => const CosOperationState(isLoading: true);
  factory CosOperationState.success({dynamic result}) => CosOperationState(isSuccess: true, result: result);
  factory CosOperationState.error(String message) => CosOperationState(error: message, isSuccess: false);
}

// 操作状态Notifier
class CosOperationNotifier extends StateNotifier<CosOperationState> {
  CosOperationNotifier() : super(CosOperationState.initial());

  // 重置状态
  void reset() {
    state = CosOperationState.initial();
  }

  // 上传文件
  Future<void> uploadFile({
    required String filePath,
    required String objectKey,
    String? contentType,
  }) async {
    try {
      state = CosOperationState.loading();
      await CosService.uploadFile(
        filePath: filePath,
        objectKey: objectKey,
        contentType: contentType,
      );
      state = CosOperationState.success(result: objectKey);
    } catch (e) {
      state = CosOperationState.error(extractErrorMessage(e));
    }
  }

  // 上传二进制数据
  Future<void> uploadObject({
    required String objectKey,
    required Uint8List fileData,
    required String contentType,
  }) async {
    try {
      state = CosOperationState.loading();
      await CosService.uploadObject(
        objectKey: objectKey,
        fileData: fileData,
        contentType: contentType,
      );
      state = CosOperationState.success(result: objectKey);
    } catch (e) {
      state = CosOperationState.error(extractErrorMessage(e));
    }
  }

  // 上传文件夹
  Future<void> uploadDirectory({
    required String localDirectory,
    required String destinationPrefix,
  }) async {
    try {
      state = CosOperationState.loading();
      final result = await CosService.uploadDirectory(
        localDirectory: localDirectory,
        destinationPrefix: destinationPrefix,
      );
      state = CosOperationState.success(result: result);
    } catch (e) {
      state = CosOperationState.error(extractErrorMessage(e));
    }
  }

  // 删除对象
  Future<void> deleteObject({required String objectKey}) async {
    try {
      state = CosOperationState.loading();
      await CosService.deleteObject(objectKey: objectKey);
      state = CosOperationState.success();
    } catch (e) {
      state = CosOperationState.error(extractErrorMessage(e));
    }
  }

  // 删除多个对象
  Future<void> deleteMultipleObjects({required List<String> objectKeys}) async {
    try {
      state = CosOperationState.loading();
      await CosService.deleteMultipleObjects(objectKeys: objectKeys);
      state = CosOperationState.success();
    } catch (e) {
      state = CosOperationState.error(extractErrorMessage(e));
    }
  }

  // 删除文件夹
  Future<void> deleteDirectory({required String directoryPath}) async {
    try {
      state = CosOperationState.loading();
      final result = await CosService.deleteDirectory(directoryPath: directoryPath);
      state = CosOperationState.success(result: result);
    } catch (e) {
      state = CosOperationState.error(extractErrorMessage(e));
    }
  }

  // 创建文件夹
  Future<void> createFolder({required String folderPath}) async {
    try {
      state = CosOperationState.loading();
      await CosService.createFolder(folderPath: folderPath);
      state = CosOperationState.success();
    } catch (e) {
      state = CosOperationState.error(extractErrorMessage(e));
    }
  }

  // 下载对象
  Future<void> downloadObject({
    required String objectKey,
    Function(int received, int total)? onProgress,
  }) async {
    try {
      state = CosOperationState.loading();
      final result = await CosService.downloadObject(
        objectKey: objectKey,
        onProgress: onProgress,
      );
      state = CosOperationState.success(result: result);
    } catch (e) {
      state = CosOperationState.error(extractErrorMessage(e));
    }
  }

  // 获取对象URL
  Future<void> getObjectUrl({required String objectKey}) async {
    try {
      state = CosOperationState.loading();
      final url = await CosService.getObjectUrl(objectKey: objectKey);
      state = CosOperationState.success(result: url);
    } catch (e) {
      state = CosOperationState.error(extractErrorMessage(e));
    }
  }

  // Select bucket (new method)
  Future<void> selectBucket({
    required String bucketName,
    required String region,
    required StateController<String?> currentBucketNotifier,
    required StateController<String?> currentRegionNotifier,
    required StateController<String> currentPrefixNotifier,
    required Function invalidateObjectsProvider,
  }) async {
    try {
      state = CosOperationState.loading();
      await CosService.updateConfig(
        bucketName: bucketName,
        region: region,
      );
      currentBucketNotifier.state = bucketName;
      currentRegionNotifier.state = region;
      currentPrefixNotifier.state = '';
      invalidateObjectsProvider();
      state = CosOperationState.success(result: 'BucketSelectedSuccessfully');
    } catch (e) {
      state = CosOperationState.error(extractErrorMessage(e));
    }
  }

  // 创建存储桶
  Future<void> createBucket({
    required String bucketName,
    required String region,
    String aclPermission = 'private',
  }) async {
    try {
      state = CosOperationState.loading();
      await CosService.createBucket(
        bucketName: bucketName,
        region: region,
        aclPermission: aclPermission,
      );
      state = CosOperationState.success(result: 'BucketCreatedSuccessfully');
    } catch (e) {
      state = CosOperationState.error(extractErrorMessage(e));
    }
  }

  // 删除存储桶
  Future<void> deleteBucket({
    required String bucketName,
    required String region,
  }) async {
    try {
      state = CosOperationState.loading();
      await CosService.deleteBucket(
        bucketName: bucketName,
        region: region,
      );
      state = CosOperationState.success(result: 'BucketDeletedSuccessfully');
    } catch (e) {
      state = CosOperationState.error(extractErrorMessage(e));
    }
  }
}

// 全局提供CosOperationNotifier
final cosOperationProvider = StateNotifierProvider<CosOperationNotifier, CosOperationState>((ref) {
  return CosOperationNotifier();
});

// Helper function to extract clean error message
String extractErrorMessage(dynamic error) {
  final errorString = error.toString();
  
  // Check for XML COS error message format
  final messageRegex = RegExp(r'<Message>(.*?)</Message>');
  final match = messageRegex.firstMatch(errorString);
  if (match != null && match.groupCount >= 1) {
    return match.group(1) ?? errorString;
  }
  
  // Check if it's an Exception with a message
  if (errorString.startsWith('Exception:')) {
    return errorString.substring('Exception:'.length).trim();
  }
  
  // If there's a colon, assume the important part is after it
  if (errorString.contains(':')) {
    return errorString.split(':').skip(1).join(':').trim();
  }
  
  return errorString;
}
