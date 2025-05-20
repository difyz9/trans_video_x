class ObjectItemModel {
  final String key;
  final String? lastModified;
  final int? size;
  final String? eTag;
  final bool isDirectory;
  
  ObjectItemModel({
    required this.key,
    this.lastModified,
    this.size,
    this.eTag,
    this.isDirectory = false,
  });
  
  String get fileName {
    final parts = key.split('/');
    return parts.isEmpty ? key : parts.last;
  }
  
  String get displaySize {
    if (size == null) return '未知';
    if (size! < 1024) return '$size B';
    if (size! < 1024 * 1024) return '${(size! / 1024).toStringAsFixed(2)} KB';
    if (size! < 1024 * 1024 * 1024) return '${(size! / (1024 * 1024)).toStringAsFixed(2)} MB';
    return '${(size! / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
  
  factory ObjectItemModel.fromCOSObject(dynamic object) {
    String key = '未知';
    String? lastModified;
    int? size;
    String? eTag;
    
    try {
      if (object is Map) {
        key = object['key'] as String? ?? '未知';
        lastModified = object['lastModified'] as String?;
        size = object['size'] as int?;
        eTag = object['eTag'] as String?;
      } else {
        key = object?.key?.toString() ?? '未知';
        
        try { lastModified = object?.lastModified?.toString(); } catch (_) {}
        try { size = object?.size is int ? object.size : null; } catch (_) {}
        try { eTag = object?.eTag?.toString(); } catch (_) {}
      }
    } catch (e) {
      print('解析COS对象出错: $e');
    }
    
    final isDir = key.endsWith('/');
    
    return ObjectItemModel(
      key: key,
      lastModified: lastModified,
      size: size,
      eTag: eTag,
      isDirectory: isDir,
    );
  }
  
  factory ObjectItemModel.fromCOSCommonPrefix(dynamic prefix) {
    String prefixString = '未知';
    
    try {
      if (prefix is Map) {
        prefixString = prefix['prefix'] as String? ?? '未知';
      } else {
        prefixString = prefix?.prefix?.toString() ?? '未知';
      }
    } catch (e) {
      print('解析COS公共前缀出错: $e');
    }
    
    return ObjectItemModel(
      key: prefixString,
      isDirectory: true,
    );
  }
  
  // 获取文件图标类型
  String getFileType() {
    if (isDirectory) return 'folder';
    
    final extension = fileName.split('.').last.toLowerCase();
    
    // 图片
    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'svg'].contains(extension)) {
      return 'image';
    }
    
    // 视频
    if (['mp4', 'mov', 'avi', 'wmv', 'flv', 'mkv', 'webm'].contains(extension)) {
      return 'video';
    }
    
    // 音频
    if (['mp3', 'wav', 'ogg', 'flac', 'm4a', 'aac'].contains(extension)) {
      return 'audio';
    }
    
    // 文档
    if (['pdf', 'doc', 'docx', 'txt', 'md', 'rtf'].contains(extension)) {
      return 'document';
    }
    
    // 表格
    if (['xls', 'xlsx', 'csv'].contains(extension)) {
      return 'spreadsheet';
    }
    
    // 演示文稿
    if (['ppt', 'pptx'].contains(extension)) {
      return 'presentation';
    }
    
    // 压缩文件
    if (['zip', 'rar', '7z', 'tar', 'gz'].contains(extension)) {
      return 'archive';
    }
    
    // 代码文件
    if (['js', 'html', 'css', 'php', 'py', 'java', 'swift', 'dart', 'json', 'xml'].contains(extension)) {
      return 'code';
    }
    
    return 'other';
  }
}