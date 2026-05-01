import 'package:hive/hive.dart';
part 'debt_data_model.g.dart';

@HiveType(typeId: 3)
class DebtData extends HiveObject {

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  double totalDebt;

  @HiveField(3)
  double totalPaid; // 🔥 NEW

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  String? note;

  DebtData({
    required this.id,
    required this.name,
    this.totalDebt = 0.0,
    this.totalPaid = 0.0,
    DateTime? createdAt,
    this.note,
  }) : createdAt = createdAt ?? DateTime.now();

  // 🔥 computed
  double get remaining => totalDebt - totalPaid;

  bool get isPaid => remaining <= 0;
}