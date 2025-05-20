import 'package:tencent_cos_plus/tencent_cos_plus.dart';
import 'package:intl/intl.dart';

class BucketModel {
  final String name;
  final String region;
  final String? creationDate;
  final String? lastModified;
  final String? location;
  final String? owner;
  
  BucketModel({
    required this.name,
    required this.region,
    this.creationDate,
    this.lastModified,
    this.location,
    this.owner,
  });
  
  // Crear un modelo de bucket a partir de la respuesta de la API de COS
  factory BucketModel.fromCOSBucket(COSBucket bucket) {
    // Formatear la fecha si está disponible
    String? formattedDate;
    if (bucket.creationDate != null) {
      try {
        final date = DateTime.parse(bucket.creationDate!);
        formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
      } catch (e) {
        formattedDate = bucket.creationDate;
      }
    }
    
    return BucketModel(
      name: bucket.name ?? '',
      region: bucket.location ?? '',
      creationDate: formattedDate,
      location: bucket.location,
      // owner: bucket.owner?.displayName,
    );
  }
  
  // Getter para mostrar el nombre de la región de manera más amigable
  String get readableRegion {
    final regionMap = {
      'ap-guangzhou': '广州',
      'ap-beijing': '北京',
      'ap-shanghai': '上海',
      'ap-chengdu': '成都',
      'ap-singapore': '新加坡',
      'na-siliconvalley': '硅谷',
      'na-ashburn': '弗吉尼亚',
      'eu-frankfurt': '法兰克福',
    };
    
    return '${regionMap[region] ?? region} ($region)';
  }
}