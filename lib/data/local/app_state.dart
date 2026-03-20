import 'package:hive/hive.dart';
import '../../models/transaction_model.dart';
import '../../models/transaction_type.dart';

class AppState {
  static late Box<TransactionData> _txBox;

  static double totalExpense = 0.0;
  static double totalIncome = 0.0;
  static double totalDebt = 0.0;
  static double totalLend = 0.0;
  static double totalReceivable = 0.0;
  static double savings = 0.0;
  static double balance = 0.0;

  /// Init Hive box
  static Future<void> init() async {
    _txBox = Hive.box<TransactionData>('transactions');
    recalculateFromBox();
  }

  /// Add transaction
  static Future<void> addTransaction(TransactionData tx) async {
    // Savings validation
    if (tx.type == TransactionType.savingsWithdraw && tx.amount > savings) {
      throw Exception(
          'Cannot withdraw more than available savings: $savings');
    }

    // Optional: Lend validation
    await _txBox.add(tx);
    recalculateFromBox();
  }

  /// Get all transactions (latest first)
  static List<TransactionData> get transactions =>
      _txBox.values.toList().reversed.toList();

  /// Recalculate totals
  static void recalculateFromBox() {
    totalExpense = 0;
    totalIncome = 0;
    totalDebt = 0;
    totalLend = 0;
    totalReceivable = 0;
    savings = 0;
    balance = 0;

    for (final tx in _txBox.values) {
      
      if (tx.isPlanned) continue;

      final amount = tx.amount;

      // Income / Expense totals
      if (tx.type == TransactionType.income) totalIncome += amount;
      if (tx.type == TransactionType.expense) totalExpense += amount;

      // Balance
      balance += amount * tx.type.balanceEffect;

      // Debt
      totalDebt += amount * tx.type.debtEffect;

      // Savings
      savings += amount * tx.type.savingsEffect;

      // Receivable / Lend
      totalReceivable += amount * tx.type.receivableEffect;
    }

    // Safety checks
    if (savings < 0) savings = 0;
    if (totalDebt < 0) totalDebt = 0;
    if (totalReceivable < 0) totalReceivable = 0;
  }
}