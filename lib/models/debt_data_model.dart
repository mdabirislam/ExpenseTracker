import 'package:hive/hive.dart';
part 'debt_data_model.g.dart';

@HiveType(typeId: 3)
class DebtData extends HiveObject {
  @HiveField(0)
  final String id; // unique UUID

  @HiveField(1)
  final String name; // person or creditor

  @HiveField(2)
  double totalDebt; // running total

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  String? note;

  DebtData({
    required this.id,
    required this.name,
    this.totalDebt = 0.0,
    DateTime? createdAt,
    this.note,
  }) : createdAt = createdAt ?? DateTime.now();
}