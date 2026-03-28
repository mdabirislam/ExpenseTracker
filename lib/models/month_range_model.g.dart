// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'month_range_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MonthRangeAdapter extends TypeAdapter<MonthRange> {
  @override
  final int typeId = 1;

  @override
  MonthRange read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MonthRange(
      start: fields[0] as DateTime,
      end: fields[1] as DateTime,
      monthRef: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, MonthRange obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.start)
      ..writeByte(1)
      ..write(obj.end)
      ..writeByte(2)
      ..write(obj.monthRef);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthRangeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
