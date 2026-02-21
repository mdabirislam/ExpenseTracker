import 'package:hive/hive.dart';
import '../../models/transaction_model.dart';
//import '../../utils/helpers.dart';
import '../.././models/transaction_type.dart';

class AppState {
  static late Box<TransactionData> _txBox;

  static double totalExpense = 0.0;
  static double totalIncome = 0.0;
  static double totalDebt = 0.0;
  static double debtToPay = 0.0;
  static double savings = 0.0;
  static double balance = 0.0;

  /// Initialize Hive box and calculate totals
  static Future<void> init() async {
    _txBox = Hive.box<TransactionData>('transactions');
    recalculateFromBox(_txBox);
    // _recalculate();
  }

  /// Add transaction and recalculate totals
  static Future<void> addTransaction(TransactionData tx) async {
    // 🔹 Future:
    // - check if source exists
    // - ask merge or rename
    // - use generateUniqueSource() from helpers.dart
    await _txBox.add(tx);
    recalculateFromBox(_txBox);
    // _recalculate();
  }

  /// Expose transactions in reverse chronological order
  static List<TransactionData> get transactions =>
      _txBox.values.toList().reversed.toList();

  /// Recalculate totals
  static void recalculateFromBox(Box<TransactionData> box) {
    totalExpense = 0.0;
    totalIncome = 0.0;
    totalDebt = 0.0;

    for (final tx in _txBox.values) {
      switch (tx.type) {
        case TransactionType.expense:
          totalExpense += tx.amount;
          break;
        case TransactionType.income:
          totalIncome += tx.amount;
          break;
        case TransactionType.debt:
          totalDebt += tx.amount;
          break;
      }
    }

    // Savings is income - expense
    savings = totalIncome - totalExpense;

    // Debt to pay is total debt minus savings
    debtToPay = totalDebt - savings;
    if (debtToPay < 0) debtToPay = 0.0;

    // Balance = income - expense - debtToPay (or can just be savings)
    balance = savings - debtToPay;
  }
}
