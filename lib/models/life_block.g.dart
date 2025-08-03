// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'life_block.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LifeBlockAdapter extends TypeAdapter<LifeBlock> {
  @override
  final int typeId = 5;

  @override
  LifeBlock read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LifeBlock.health;
      case 1:
        return LifeBlock.career;
      case 2:
        return LifeBlock.family;
      case 3:
        return LifeBlock.finances;
      case 4:
        return LifeBlock.education;
      case 5:
        return LifeBlock.hobbies;
      case 6:
        return LifeBlock.spirituality;
      case 7:
        return LifeBlock.relationships;
      default:
        return LifeBlock.health;
    }
  }

  @override
  void write(BinaryWriter writer, LifeBlock obj) {
    switch (obj) {
      case LifeBlock.health:
        writer.writeByte(0);
        break;
      case LifeBlock.career:
        writer.writeByte(1);
        break;
      case LifeBlock.family:
        writer.writeByte(2);
        break;
      case LifeBlock.finances:
        writer.writeByte(3);
        break;
      case LifeBlock.education:
        writer.writeByte(4);
        break;
      case LifeBlock.hobbies:
        writer.writeByte(5);
        break;
      case LifeBlock.spirituality:
        writer.writeByte(6);
        break;
      case LifeBlock.relationships:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LifeBlockAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
