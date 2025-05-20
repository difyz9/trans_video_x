import 'package:tencent_cos_plus/tencent_cos_plus.dart';

class BucketModel {
  final String name;
  final String region;
  final String? creationDate;
  int objectCount = 0;
  int totalSize = 0;
  
  BucketModel({
    required this.name,
    required this.region,
    this.creationDate,
    this.objectCount = 0,
    this.totalSize = 0,
  });
  
  String get displaySize {
    if (totalSize < 1024) return '$totalSize B';
    if (totalSize < 1024 * 1024) return '${(totalSize / 1024).toStringAsFixed(2)} KB';
    if (totalSize < 1024 * 1024 * 1024) return '${(totalSize / (1024 * 1024)).toStringAsFixed(2)} MB';
    return '${(totalSize / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
  
  factory BucketModel.fromCOSBucket(COSBucket bucket) {
    // 提取存储桶名称（移除AppId后缀）
    final nameWithoutAppId = bucket.name?.split('-').take((bucket.name?.split('-').length ?? 0) - 1).join('-');
    
    return BucketModel(
      name: nameWithoutAppId ?? bucket.name ?? '未知',
      region: bucket.location ?? '未知',
      creationDate: bucket.creationDate,
    );
  }
  
  // 根据地区代码获取中文名称
  String get regionName {
    final regionCodes = {
      'ap-guangzhou': '广州',
      'ap-shanghai': '上海',
      'ap-beijing': '北京',
      'ap-chengdu': '成都',
      'ap-chongqing': '重庆',
      'ap-hongkong': '香港',
      'ap-singapore': '新加坡',
      'ap-tokyo': '东京',
      'na-toronto': '多伦多',
      'na-siliconvalley': '硅谷',
      'na-ashburn': '弗吉尼亚',
      'eu-frankfurt': '法兰克福',
    };
    
    return regionCodes[region] ?? region;
  }
  
  // 添加 readableRegion getter 作为 regionName 的别名
  String get readableRegion => regionName;
}