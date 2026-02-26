// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debt_data_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DebtDataAdapter extends TypeAdapter<DebtData> {
  @override
  final int typeId = 3;

  @override
  DebtData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DebtData(
      id: fields[0] as String,
      name: fields[1] as String,
      totalDebt: fields[2] as double,
      createdAt: fields[3] as DateTime?,
      note: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DebtData obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.totalDebt)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DebtDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
