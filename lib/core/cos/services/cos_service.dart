import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:tencent_cos_plus/tencent_cos_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class CosService {
  static String? _currentBucketName;
  static String? _currentRegion;
  
  // Initialize the COS service
  static Future<void> initialize({
    required String appId,
    required String secretId,
    required String secretKey,
    required String bucketName,
    required String region,
  }) async {
    try {
      _currentBucketName = bucketName;
      _currentRegion = region;
      
      // Initialize COS API
      COSApiFactory.initialize(
        config: COSConfig(
          appId: appId,
          secretId: secretId,
          secretKey: secretKey,
        ),
        bucketName: bucketName,
        region: region,
      );
      
      // Save credentials using SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cos_appId', appId);
      await prefs.setString('cos_secretId', secretId);
      await prefs.setString('cos_secretKey', secretKey);
      await prefs.setString('cos_bucketName', bucketName);
      await prefs.setString('cos_region', region);
      
      debugPrint('COS service initialized successfully');
    } catch (e) {
      debugPrint('Error initializing COS service: $e');
      rethrow;
    }
  }
  
  // Update configuration
  static Future<void> updateConfig({
    String? appId,
    String? secretId,
    String? secretKey,
    String? bucketName,
    String? region,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final currentAppId = prefs.getString('cos_appId');
    final currentSecretId = prefs.getString('cos_secretId');
    final currentSecretKey = prefs.getString('cos_secretKey');
    
    await initialize(
      appId: appId ?? currentAppId ?? '',
      secretId: secretId ?? currentSecretId ?? '',
      secretKey: secretKey ?? currentSecretKey ?? '',
      bucketName: bucketName ?? _currentBucketName ?? '',
      region: region ?? _currentRegion ?? '',
    );
  }
  
  // Get current bucket and region
  static String? get currentBucketName => _currentBucketName;
  static String? get currentRegion => _currentRegion;
  
  // BUCKET OPERATIONS
  
  // List all buckets
  static Future<List<COSBucket>> listAllBuckets() async {
    try {
      final result = await COSApiFactory.bucketApi.getService(region: _currentRegion!);
      return result.buckets ?? [];
    } catch (e) {
      debugPrint('Failed to list buckets: $e');
      throw Exception('获取存储桶列表失败: $e');
    }
  }
  
  // Upload object
  static Future<void> uploadObject({
    required String objectKey,
    required Uint8List fileData,
    required String contentType,
    Function(int sent, int total)? onSendProgress,
  }) async {
    try {
      await COSApiFactory.objectApi.putObject(
        bucketName: _currentBucketName!,
        region: _currentRegion!,
        objectKey: objectKey,
        objectValue: fileData,
        contentType: contentType,
      );
      onSendProgress?.call(fileData.length, fileData.length);
    } catch (e) {
      throw Exception('Failed to upload object: $e');
    }
  }
  
  // Upload a single file with path information
  static Future<void> uploadFile({
    required String filePath,
    required String objectKey,
    String? contentType,
    Function(int sent, int total)? onSendProgress,
  }) async {
    try {
      final file = File(filePath);
      final fileData = await file.readAsBytes(); 
      
      final effectiveContentType = contentType ?? _getMimeTypeFromPath(filePath);
      
      await COSApiFactory.objectApi.putObject(
        bucketName: _currentBucketName!,
        region: _currentRegion!,
        objectKey: objectKey,
        objectValue: fileData,
        contentType: effectiveContentType,
      );
      onSendProgress?.call(fileData.length, fileData.length);
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }
  

  // Create bucket
  static Future<void> createBucket({
    required String bucketName,
    required String region,
    String aclPermission = 'private',
  }) async {
    try {
      await COSApiFactory.bucketApi.putBucket(
        bucketName: bucketName,
        region: region,
        aclHeader: COSACLHeader()..xCosAcl = aclPermission,
      );
    } catch (e) {
      debugPrint('Failed to create bucket: $e');
      throw Exception('创建存储桶失败: $e');
    }
  }
  // Delete object
  static Future<void> deleteObject({
    required String objectKey,
  }) async {
    try {
      await COSApiFactory.objectApi.deleteObject(
        bucketName: _currentBucketName!,
        region: _currentRegion!,
        objectKey: objectKey,
      );
    } catch (e) {
      throw Exception('Failed to delete object: $e');
    }
  }

  // Delete multiple objects in a single request
  static Future<void> deleteMultipleObjects({
    required List<String> objectKeys,
  }) async {
    try {
      if (objectKeys.isEmpty) {
        return; // Nothing to delete
      }
      
      // Create a list of COSObject objects as required by the API
      final objects = objectKeys
          .map((key) => COSObject(key: key))
          .toList();
      
      // Create a COSDelete object with the list of objects to delete
      final delete = COSDelete(
        quiet: true, // Set to true to use quiet mode (only returns errors)
        objects: objects, 
      );
      
      await COSApiFactory.objectApi.deleteMultipleObjects(
        bucketName: _currentBucketName!,
        region: _currentRegion!,
        delete: delete,
      );
    } catch (e) {
      throw Exception('Failed to delete multiple objects: $e');
    }
  }

  // Delete a directory and all its contents
  static Future<bool> deleteDirectory({
    required String directoryPath,
  }) async {
    try {
      print('Attempting to delete directory: $directoryPath');
      
      // Ensure the path ends with a slash (required for folder semantics)
      final path = directoryPath.endsWith('/') ? directoryPath : '$directoryPath/';
      
      // Use the native deleteDirectory API from Tencent COS SDK
      final result = await COSApiFactory.objectApi.deleteDirectory(
        bucketName: _currentBucketName!,
        region: _currentRegion!,
        directory: path,
      );
      
      // If the SDK method fails, the result will be false
      if (!result) {
        print('SDK deleteDirectory method returned false, will try manual deletion');
        // Fall back to manual directory deletion
        await _manualDeleteDirectory(path);
      }
      
      return true;
    } catch (e) {
      print('Error deleting directory: $e');
      
      // Try fallback manual method if the SDK method throws an exception
      try {
        await _manualDeleteDirectory(directoryPath);
        return true;
      } catch (fallbackError) {
        print('Fallback deletion also failed: $fallbackError');
        throw Exception('Failed to delete directory: $e');
      }
    }
  }
  
    // Delete bucket
  static Future<void> deleteBucket({
    required String bucketName,
    required String region,
  }) async {
    try {
      await COSApiFactory.bucketApi.deleteBucket(
        bucketName: bucketName, 
        region: region
      );
    } catch (e) {
      throw Exception('Failed to delete bucket: $e');
    }
  }
  
  
  // Manual directory deletion as a fallback method
  static Future<void> _manualDeleteDirectory(String directoryPath) async {
    // Ensure the path ends with a slash (required for folder semantics)
    final path = directoryPath.endsWith('/') ? directoryPath : '$directoryPath/';
    
    // 1. List all objects with the directory prefix
    final result = await listObjects(prefix: path);
    
    // 2. Extract all object keys from the result
    List<String> objectKeys = [];
    if (result.contents != null) {
      final contents = result.contents as List;
      for (final object in contents) {
        if (object.key != null) {
          objectKeys.add(object.key as String);
        }
      }
    }
    
    // 3. Delete all objects in batches (if any found)
    if (objectKeys.isNotEmpty) {
      // Delete in batches of 1000 (COS limit for batch operations)
      for (int i = 0; i < objectKeys.length; i += 1000) {
        final endIndex = (i + 1000 < objectKeys.length) ? i + 1000 : objectKeys.length;
        final batch = objectKeys.sublist(i, endIndex);
        
        await deleteMultipleObjects(objectKeys: batch);
      }
    }
    
    // 4. Finally delete the directory marker itself
    await deleteObject(objectKey: path);
  }
  // OBJECT OPERATIONS
  
  // List objects in bucket
  static Future<dynamic> listObjects({
    String? prefix,
    String? delimiter,
    int? maxKeys,
  }) async {
    try {
      final header = COSListObjectHeader();
      if (prefix != null) header.prefix = prefix;
      if (delimiter != null) header.delimiter = delimiter;
      if (maxKeys != null) header.maxKeys = maxKeys;
      
      final result = await COSApiFactory.objectApi.listObjects(
        bucketName: _currentBucketName!,
        region: _currentRegion!,
        listObjectHeader: header,
      );
      
      return result;
    } catch (e) {
      debugPrint('Failed to list objects: $e');
      throw Exception('获取对象列表失败: $e');
    }
  }
  
  // Download object
  static Future<Uint8List> downloadObject({
    required String objectKey,
    Function(int received, int total)? onProgress,
  }) async {
    try {
      // First get object metadata to get file size
      final metadata = await COSApiFactory.objectApi.headObject(
        bucketName: _currentBucketName!,
        region: _currentRegion!,
        objectKey: objectKey,
      );
      
      int contentLength = 0;
      if (metadata.contentLength != null) {
        contentLength = metadata.contentLength as int;
      }

      // Set download query parameters
      final getObjectQuery = COSGetObjectQuery()
        ..responseCacheControl = 'no-cache';
      
      // For progress tracking, we need custom implementation
      if (onProgress != null && contentLength > 0) {
        return await _downloadObjectWithProgress(
          objectKey: objectKey,
          contentLength: contentLength,
          onProgress: onProgress,
        );
      }
      
      // Default download
      dynamic result = await COSApiFactory.objectApi.getObject(
        bucketName: _currentBucketName!,
        region: _currentRegion!,
        objectKey: objectKey,
        getObjectQuery: getObjectQuery,
      );
      
      // Handle different possible response types
      if (result != null) {
        if (result.bodyBytes != null) {
          return result.bodyBytes;
        } else if (result.objectValue != null) {
          return result.objectValue;
        } else if (result is Uint8List) {
          return result;
        }
        
        debugPrint('COS API returned unexpected type: ${result.runtimeType}');
      }
      
      throw Exception('无法从腾讯云API响应中提取数据');
    } catch (e) {
      debugPrint('Failed to download object: $e');
      throw Exception('下载对象失败: $e');
    }
  }
  
  // Progress-tracking download helper
  static Future<Uint8List> _downloadObjectWithProgress({
    required String objectKey,
    required int contentLength,
    required Function(int received, int total) onProgress,
  }) async {
    try {
      final result = await COSApiFactory.objectApi.getObject(
        bucketName: _currentBucketName!,
        region: _currentRegion!,
        objectKey: objectKey,
      );
      
      if (result.bodyBytes != null) {
        final bytes = result.bodyBytes;
        // Simulate progress (due to SDK limitations, we can only update on completion)
        onProgress(bytes.length, bytes.length);
        return bytes;
      } else {
        throw Exception('从腾讯云API获取的响应格式无效');
      }
    } catch (e) {
      throw Exception('下载对象失败: $e');
    }
  }
  

  // Create folder
  static Future<void> createFolder({
    required String folderPath,
  }) async {
    try {
      // In COS, folders are just objects with a trailing slash and empty content
      final path = folderPath.endsWith('/') ? folderPath : '$folderPath/';
      final emptyContent = Uint8List(0);
      
      await COSApiFactory.objectApi.putObject(
        bucketName: _currentBucketName!,
        region: _currentRegion!,
        objectKey: path,
        objectValue: emptyContent,
        contentType: 'application/x-directory',
      );
    } catch (e) {
      debugPrint('Failed to create folder: $e');
      throw Exception('创建文件夹失败: $e');
    }
  }
  

  // Helper method to determine MIME type from file path
  static String _getMimeTypeFromPath(String path) {
    final extension = path.split('.').last.toLowerCase();
    
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
      case 'gif':
      case 'webp':
        return 'image/webp';
      case 'pdf':
        return 'application/pdf';
      case 'txt':
        return 'text/plain';
      case 'html':
        return 'text/html';
      case 'css':
        return 'text/css';
      case 'js':
        return 'application/javascript';
      case 'json':
        return 'application/json';
      case 'xml':
        return 'application/xml';
      case 'zip':
        return 'application/zip';
      default:
        return 'application/octet-stream';
    }
  }
  

  // Upload a directory and all its contents with improved error handling
  static Future<bool> uploadDirectory({
    required String localDirectory,
    required String destinationPrefix,
  }) async {
    try {
      print('Starting upload of directory: $localDirectory to $destinationPrefix');
      
      // Instead of using the SDK method, let's implement our own directory upload
      // to have better control over the process and avoid signature issues
      final directory = Directory(localDirectory);
      if (!directory.existsSync()) {
        throw Exception('Directory does not exist: $localDirectory');
      }
      
      // Create the destination folder first
      final destPath = destinationPrefix.endsWith('/') 
          ? destinationPrefix 
          : '$destinationPrefix/';
          
      await createFolder(folderPath: destPath);
      print('Created destination folder: $destPath');
      
      // Process all files in the directory (non-recursive first)
      final entities = directory.listSync(recursive: false);
      int successCount = 0;
      int errorCount = 0;
      
      for (final entity in entities) {
        try {
          final name = entity.path.split(Platform.pathSeparator).last;
          
          if (entity is File) {
            // Upload file
            final fileBytes = await entity.readAsBytes();
            final objectKey = '$destPath$name';
            final contentType = _getMimeTypeFromPath(entity.path);
            
            print('Uploading file: ${entity.path} to $objectKey');
            await uploadObject(
              objectKey: objectKey,
              fileData: fileBytes,
              contentType: contentType,
            );
            successCount++;
          } else if (entity is Directory) {
            // Recursively upload subdirectory
            final subDestPath = '$destPath$name/';
            final success = await uploadDirectory(
              localDirectory: entity.path,
              destinationPrefix: subDestPath,
            );
            
            if (success) successCount++;
            else errorCount++;
          }
        } catch (e) {
          print('Error processing entity ${entity.path}: $e');
          errorCount++;
        }
      }
      
      print('Directory upload completed. Success: $successCount, Errors: $errorCount');
      return errorCount == 0; // Consider success only if no errors
    } catch (e) {
      print('Error in uploadDirectory: $e');
      throw Exception('Failed to upload directory: $e');
    }
  }

  /// Get a temporary URL for accessing an object
  static Future<String> getObjectUrl({required String objectKey}) async {
    try {
      // Construct a public URL for the object based on COS URL pattern
      // Format: https://<bucketName>-<APPID>.cos.<region>.myqcloud.com/<objectKey>
      final prefs = await SharedPreferences.getInstance();
      final appId = prefs.getString('cos_appId') ?? '1253459663';
      
      // URL encode the object key to handle special characters properly
      final encodedKey = Uri.encodeComponent(objectKey);
      
      // Build the URL
      final url = 'https://${_currentBucketName}-$appId.cos.${_currentRegion}.myqcloud.com/$encodedKey';
      
      return url;
    } catch (e) {
      print('Error getting object URL: $e');
      throw Exception('Failed to get object URL: $e');
    }
  }
  // Helper method to determine MIME type from file path
  static String getMimeTypeFromPath(String path) {
    final extension = path.split('.').last.toLowerCase();
    
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'pdf':
        return 'application/pdf';
      case 'txt':
        return 'text/plain';
      case 'html':
        return 'text/html';
      case 'css':
        return 'text/css';
      case 'js':
        return 'application/javascript';
      case 'json':
        return 'application/json';
      case 'xml':
        return 'application/xml';
      case 'zip':
        return 'application/zip';
      default:
        return 'application/octet-stream';
    }
  }
 
}