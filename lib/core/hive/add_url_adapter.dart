

import 'package:hive/hive.dart';
import 'package:trans_video_x/models/add_url_model.dart';

class AddUrlAdapter extends TypeAdapter<AddUrlModel> {
  @override
  final int typeId = 1; // 应与 @HiveType(typeId: 1) 匹配

  @override
  AddUrlModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final field = reader.readByte();
      fields[field] = reader.read();
    }
    return AddUrlModel(
      id: fields[0] as String?,
      url: fields[1] as String?,
      title: fields[2] as String?,
      description: fields[3] as String?,
      playlistId: fields[4] as String?,
      operationType: fields[5] as String?,
      timestamp: fields[6] as DateTime,
      status: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AddUrlModel obj) {
    writer.writeByte(8); // 字段总数
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.url);
    writer.writeByte(2);
    writer.write(obj.title);
    writer.writeByte(3);
    writer.write(obj.description);
    writer.writeByte(4);
    writer.write(obj.playlistId);
    writer.writeByte(5);
    writer.write(obj.operationType);
    writer.writeByte(6);
    writer.write(obj.timestamp);
    writer.writeByte(7);
    writer.write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddUrlModel &&
          runtimeType == other.runtimeType;
}
