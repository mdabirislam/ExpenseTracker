import 'package:hive/hive.dart';
//import '../utils/helpers.dart';
import 'transaction_type.dart';
part 'transaction_model.g.dart';

@HiveType(typeId: 0)
class TransactionData extends HiveObject {
  @HiveField(0)
  final TransactionType type; // expense / income / debt

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final String source; // user input

  @HiveField(3)
  final String? note; // optional

  @HiveField(4)
  final DateTime date;

  TransactionData({
    required this.type,
    required this.amount,
    required this.source,
    this.note,
    required this.date,
  });
}
