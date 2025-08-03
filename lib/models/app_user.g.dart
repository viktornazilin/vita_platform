// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppUserAdapter extends TypeAdapter<AppUser> {
  @override
  final int typeId = 0;

  @override
  AppUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppUser(
      id: fields[0] as String,
      email: fields[1] as String,
      password: fields[2] as String,
      name: fields[3] as String?,
      age: fields[4] as int?,
      health: fields[5] as String?,
      goals: fields[6] as String?,
      dreams: fields[7] as String?,
      strengths: fields[8] as String?,
      weaknesses: fields[9] as String?,
      priorities: (fields[10] as List?)?.cast<String>(),
      lifeBlocks: (fields[11] as List?)?.cast<LifeBlock>(),
      hasCompletedQuestionnaire: fields[12] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AppUser obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.password)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.age)
      ..writeByte(5)
      ..write(obj.health)
      ..writeByte(6)
      ..write(obj.goals)
      ..writeByte(7)
      ..write(obj.dreams)
      ..writeByte(8)
      ..write(obj.strengths)
      ..writeByte(9)
      ..write(obj.weaknesses)
      ..writeByte(10)
      ..write(obj.priorities)
      ..writeByte(11)
      ..write(obj.lifeBlocks)
      ..writeByte(12)
      ..write(obj.hasCompletedQuestionnaire);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
