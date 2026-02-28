import 'package:hive/hive.dart'; 
import '../../models/transaction_model.dart';
import '../../models/transaction_type.dart';

class TransactionService {
  static Box<TransactionData> get _box =>
      Hive.box<TransactionData>('transactions');

  /// 🔹 Get all transactions
  static List<TransactionData> getAll() => _box.values.toList();

  /// 🔹 Get transactions by type
  static List<TransactionData> getByType(TransactionType type) =>
      _box.values.where((tx) => tx.type == type).toList();

  /// 🔹 Get transactions by monthKey
  static List<TransactionData> getByMonth(String monthKey) =>
      _box.values.where((tx) => tx.monthKey == monthKey).toList();

  /// 🔹 Add transaction
  static Future<void> add(TransactionData tx) async {
    await _box.add(tx);
  }

  /// 🔹 Update transaction
  static Future<void> update(TransactionData tx) async {
    await tx.save();
  }

  /// 🔹 Delete transaction
  static Future<void> delete(TransactionData tx) async {
    await tx.delete();
  }

  /// 🔹 Get total amount by type
  static double totalByType(TransactionType type) =>
      _box.values
          .where((tx) => tx.type == type)
          .fold(0.0, (sum, tx) => sum + tx.amount);
}