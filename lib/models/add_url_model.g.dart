// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_url_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AddUrlModelAdapter extends TypeAdapter<AddUrlModel> {
  @override
  final int typeId = 1;

  @override
  AddUrlModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AddUrlModel(
      id: fields[0] as String?,
      url: fields[1] as String?,
      title: fields[2] as String?,
      description: fields[3] as String?,
      playlistId: fields[4] as String?,
      operationType: fields[5] as String?,
      timestamp: fields[6] as DateTime?,
      status: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AddUrlModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.url)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.playlistId)
      ..writeByte(5)
      ..write(obj.operationType)
      ..writeByte(6)
      ..write(obj.timestamp)
      ..writeByte(7)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddUrlModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
