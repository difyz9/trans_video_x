
import 'package:uuid/uuid.dart'; 

class AddUrlModel {

  final String? id; // 添加ID字段以唯一标识每条记录


  final String? url;
  

  final String? title;
  

  final String? description;
  

  final String? playlistId;
  

  final String? operationType;


  final DateTime timestamp; // 添加时间戳字段


  final String? status; // 处理状态

  AddUrlModel({
    String? id,
    this.url,
    this.title,
    this.description,
    this.playlistId,
    this.operationType,
    DateTime? timestamp,
    this.status
  }) : this.id = id ?? const Uuid().v4(),
       this.timestamp = timestamp ?? DateTime.now();


 factory AddUrlModel.fromJson(Map<String, dynamic> json) {
    return AddUrlModel(
      id: json['id'] as String?,
      url: json['url'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      playlistId: json['playlistId'] as String?,
      operationType: json['operationType'] as String?,
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : null,
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'title': title,
      'description': description,
      'playlistId': playlistId,
      'operationType': operationType,
    };
  }
  
}