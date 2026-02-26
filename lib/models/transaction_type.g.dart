// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionTypeAdapter extends TypeAdapter<TransactionType> {
  @override
  final int typeId = 2;

  @override
  TransactionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TransactionType.income;
      case 1:
        return TransactionType.expense;
      case 2:
        return TransactionType.debtBorrow;
      case 3:
        return TransactionType.debtRepay;
      case 4:
        return TransactionType.creditBuy;
      case 5:
        return TransactionType.creditPay;
      case 6:
        return TransactionType.savingsAdd;
      case 7:
        return TransactionType.savingsWithdraw;
      case 8:
        return TransactionType.lendGive;
      case 9:
        return TransactionType.lendReceive;
      default:
        return TransactionType.income;
    }
  }

  @override
  void write(BinaryWriter writer, TransactionType obj) {
    switch (obj) {
      case TransactionType.income:
        writer.writeByte(0);
        break;
      case TransactionType.expense:
        writer.writeByte(1);
        break;
      case TransactionType.debtBorrow:
        writer.writeByte(2);
        break;
      case TransactionType.debtRepay:
        writer.writeByte(3);
        break;
      case TransactionType.creditBuy:
        writer.writeByte(4);
        break;
      case TransactionType.creditPay:
        writer.writeByte(5);
        break;
      case TransactionType.savingsAdd:
        writer.writeByte(6);
        break;
      case TransactionType.savingsWithdraw:
        writer.writeByte(7);
        break;
      case TransactionType.lendGive:
        writer.writeByte(8);
        break;
      case TransactionType.lendReceive:
        writer.writeByte(9);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
