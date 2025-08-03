// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'xp.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class XPAdapter extends TypeAdapter<XP> {
  @override
  final int typeId = 2;

  @override
  XP read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return XP(
      currentXP: fields[0] as int,
      level: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, XP obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.currentXP)
      ..writeByte(1)
      ..write(obj.level);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is XPAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
