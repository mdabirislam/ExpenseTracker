import 'package:hive/hive.dart';
import 'transaction_type.dart';
part 'transaction_model.g.dart';

@HiveType(typeId: 0)
class TransactionData extends HiveObject {
  @HiveField(0) final String id;
  @HiveField(1) final TransactionType type;
  @HiveField(2) final double amount;
  @HiveField(3) final String category;
  @HiveField(4) final String source;
  @HiveField(5) final String? person;
  @HiveField(6) final String? note;
  @HiveField(7) final DateTime date;
  @HiveField(8) final String monthKey;
  @HiveField(9) final int? priorityLevel;
  @HiveField(10) final bool isArchived;
  @HiveField(11) final bool isCleared;
  @HiveField(12) final bool isPlanned;

TransactionData({
  required this.id,
  required this.type,
  required this.amount,
  this.category = 'Others',
  required this.source,
  this.person,
  this.note,
  DateTime? date,
  String? monthKey,
  this.priorityLevel,
  this.isArchived = false,
  this.isCleared = false,
  this.isPlanned = false,
})  : date = date ?? DateTime.now(),
      monthKey = monthKey ??
          "${(date ?? DateTime.now()).year}-${(date ?? DateTime.now()).month.toString().padLeft(2, '0')}";
}