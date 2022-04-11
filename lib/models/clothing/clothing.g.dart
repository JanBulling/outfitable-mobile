// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clothing.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClothingAdapter extends TypeAdapter<Clothing> {
  @override
  final int typeId = 0;

  @override
  Clothing read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Clothing(
      type: fields[0] as int,
      part: fields[1] as int,
      temperatures: (fields[2] as List).cast<int>(),
      styles: (fields[3] as List).cast<int>(),
      colorValue: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Clothing obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.part)
      ..writeByte(2)
      ..write(obj.temperatures)
      ..writeByte(3)
      ..write(obj.styles)
      ..writeByte(4)
      ..write(obj.colorValue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClothingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
