// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionDataAdapter extends TypeAdapter<TransactionData> {
  @override
  final int typeId = 0;

  @override
  TransactionData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransactionData(
      id: fields[0] as String,
      type: fields[1] as TransactionType,
      amount: fields[2] as double,
      category: fields[3] as String,
      source: fields[4] as String,
      person: fields[5] as String?,
      note: fields[6] as String?,
      date: fields[7] as DateTime?,
      monthKey: fields[8] as String?,
      priorityLevel: fields[9] as int?,
      isArchived: fields[10] as bool,
      isCleared: fields[11] as bool,
      isPlanned: fields[12] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, TransactionData obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.source)
      ..writeByte(5)
      ..write(obj.person)
      ..writeByte(6)
      ..write(obj.note)
      ..writeByte(7)
      ..write(obj.date)
      ..writeByte(8)
      ..write(obj.monthKey)
      ..writeByte(9)
      ..write(obj.priorityLevel)
      ..writeByte(10)
      ..write(obj.isArchived)
      ..writeByte(11)
      ..write(obj.isCleared)
      ..writeByte(12)
      ..write(obj.isPlanned);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
