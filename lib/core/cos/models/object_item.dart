import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

class ObjectItemModel {
  final String key;
  final String? lastModified;
  final String? eTag;
  final int? size;
  final String? owner;
  final String? storageClass;
  final bool isFolder;
  
  // 添加 isDirectory getter，确保兼容性
  bool get isDirectory => isFolder;

    String get fileName {
    final parts = key.split('/');
    return parts.isEmpty ? key : parts.last;
  }

   String get displaySize {
    if (size == null) return 'Unknown';
    if (size! < 1024) return '$size B';
    if (size! < 1024 * 1024) return '${(size! / 1024).toStringAsFixed(2)} KB';
    if (size! < 1024 * 1024 * 1024) return '${(size! / (1024 * 1024)).toStringAsFixed(2)} MB';
    return '${(size! / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
  
  
  ObjectItemModel({
    required this.key,
    this.lastModified,
    this.eTag,
    this.size,
    this.owner,
    this.storageClass,
    this.isFolder = false,
  });
  
  // 从 COSObject 创建模型，使用防御性编程方式
  factory ObjectItemModel.fromCOSObject(dynamic object) {
    String key = 'Unknown';
    String? lastModified;
    String? eTag;
    int? size;
    String? owner;
    String? storageClass;
    
    try {
      // 尝试安全地获取所有属性
      if (object is Map) {
        // 如果是Map类型，直接从键值对获取
        key = object['key'] as String? ?? 'Unknown';
        lastModified = object['lastModified'] as String?;
        eTag = object['eTag'] as String?;
        size = object['size'] as int?;
        owner = object['owner']?['displayName'] as String?;
        storageClass = object['storageClass'] as String?;
      } else {
        // 使用动态访问方式获取属性，捕获可能的异常
        try { key = object?.key?.toString() ?? 'Unknown'; } catch (_) {}
        try { lastModified = object?.lastModified?.toString(); } catch (_) {}
        try { eTag = object?.eTag?.toString(); } catch (_) {}
        try { size = object?.size is int ? object.size : null; } catch (_) {}
        try { owner = object?.owner?.displayName?.toString(); } catch (_) {}
        try { storageClass = object?.storageClass?.toString(); } catch (_) {}
      }
    } catch (e) {
      print('Error parsing COS object: $e');
    }
    
    // 格式化日期
    String? formattedDate;
    if (lastModified != null) {
      try {
        final date = DateTime.parse(lastModified);
        final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
        formattedDate = formatter.format(date);
      } catch (e) {
        formattedDate = lastModified;
      }
    }
    
    final isFolder = key.endsWith('/');
    
    return ObjectItemModel(
      key: key,
      lastModified: formattedDate,
      eTag: eTag,
      size: size,
      owner: owner,
      storageClass: storageClass,
      isFolder: isFolder,
    );
  }
  
  // 添加 fromCOSCommonPrefix 工厂方法
  factory ObjectItemModel.fromCOSCommonPrefix(dynamic prefix) {
    String key = 'Unknown/';
    
    try {
      if (prefix is Map) {
        key = prefix['prefix'] as String? ?? 'Unknown/';
      } else {
        try { key = prefix?.prefix?.toString() ?? 'Unknown/'; } catch (_) {}
      }
    } catch (e) {
      print('Error parsing COS common prefix: $e');
    }
    
    return ObjectItemModel(
      key: key,
      isFolder: true,
    );
  }
  
  // Factory para crear un objeto de tipo carpeta
  factory ObjectItemModel.folder(String key) {
    return ObjectItemModel(
      key: key.endsWith('/') ? key : '$key/',
      isFolder: true,
    );
  }
  
  // Factory para el objeto de "regresar"
  factory ObjectItemModel.parent() {
    return ObjectItemModel(
      key: '../',
      isFolder: true,
    );
  }
  
  // Nombre del objeto para mostrar (sin la ruta completa)
  String get name {
    if (key == '../') {
      return '..';
    }
    
    final String fileName = path.basename(key);
    return isFolder ? (fileName.isEmpty ? path.basename(path.dirname(key)) : fileName) : fileName;
  }
  
  // Extensión de archivo (solo para archivos)
  String get extension {
    if (isFolder) return '';
    return path.extension(key).toLowerCase();
  }
  
  // Tamaño legible para humanos
  String get readableSize {
    if (isFolder) return '--';
    if (size == null) return '--';
    
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    int i = 0;
    double sizeValue = size!.toDouble();
    
    while (sizeValue >= 1024 && i < units.length - 1) {
      sizeValue /= 1024;
      i++;
    }
    
    return '${sizeValue.toStringAsFixed(2)} ${units[i]}';
  }
  
  // Determinar el icono según el tipo de archivo
  String get iconForFile {
    if (isFolder) {
      return 'folder';
    }
    
    switch (extension) {
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.gif':
      case '.bmp':
      case '.webp':
        return 'image';
      case '.mp4':
      case '.avi':
      case '.mov':
      case '.wmv':
      case '.flv':
      case '.mkv':
        return 'video';
      case '.mp3':
      case '.wav':
      case '.ogg':
      case '.flac':
      case '.aac':
        return 'audio';
      case '.pdf':
        return 'pdf';
      case '.doc':
      case '.docx':
        return 'word';
      case '.xls':
      case '.xlsx':
        return 'excel';
      case '.ppt':
      case '.pptx':
        return 'presentation';
      case '.zip':
      case '.rar':
      case '.7z':
      case '.tar':
      case '.gz':
        return 'archive';
      case '.txt':
      case '.md':
        return 'text';
      default:
        return 'file';
    }
  }
}