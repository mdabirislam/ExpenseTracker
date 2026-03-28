import 'package:hive/hive.dart';
import '../../models/transaction_model.dart';
import '../../models/transaction_type.dart';
import '../../models/month_range_model.dart';

class AppState {
  static late Box<TransactionData> _txBox;
  static late Box<MonthRange> _monthBox;

  // ================== GLOBAL TOTALS ==================
  static double totalExpense = 0.0;
  static double totalIncome = 0.0;
  static double totalDebt = 0.0;
  static double totalLend = 0.0;
  static double totalReceivable = 0.0;
  static double savings = 0.0;
  static double balance = 0.0;

  // ================== INIT ==================
  static Future<void> init() async {
    _txBox = Hive.box<TransactionData>('transactions');
    await initMonths();
    recalculateFromBox();
  }

  static Future<void> initMonths() async {
    if (!Hive.isBoxOpen('monthRanges')) {
      _monthBox = await Hive.openBox<MonthRange>('monthRanges');
    } else {
      _monthBox = Hive.box<MonthRange>('monthRanges');
    }
  }

  // ================== MONTH RANGE ==================

  /// Save or update month (overwrite if exists)
  static Future<void> saveMonth(MonthRange range) async {
    final index = _monthBox.values.toList().indexWhere((m) =>
        m.monthRef.year == range.monthRef.year &&
        m.monthRef.month == range.monthRef.month);

    if (index != -1) {
      // ✅ overwrite existing month
      await _monthBox.putAt(index, range);
    } else {
      // ✅ add new month
      await _monthBox.add(range);
    }
  }

  /// Get specific month by monthRef
  static MonthRange? getMonth(DateTime monthRef) {
    try {
      return _monthBox.values.firstWhere((m) =>
          m.monthRef.year == monthRef.year &&
          m.monthRef.month == monthRef.month);
    } catch (_) {
      return null;
    }
  }

  /// Get current month (based on today)
  static MonthRange? getCurrentMonthRange() {
    final now = DateTime.now();
    return getMonth(DateTime(now.year, now.month));
  }

  /// All months
  static List<MonthRange> get allMonths => _monthBox.values.toList();

  // ================== TRANSACTION ==================

  static Future<void> addTransaction(TransactionData tx) async {
    if (tx.type == TransactionType.savingsWithdraw && tx.amount > savings) {
      throw Exception('Cannot withdraw more than available savings: $savings');
    }

    await _txBox.add(tx);
    recalculateFromBox();
  }

  static List<TransactionData> get transactions =>
      _txBox.values.toList().reversed.toList();

  // ================== CALCULATION ==================

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

      if (tx.type == TransactionType.income) totalIncome += amount;
      if (tx.type == TransactionType.expense) totalExpense += amount;

      balance += amount * tx.type.balanceEffect;
      totalDebt += amount * tx.type.debtEffect;
      savings += amount * tx.type.savingsEffect;
      totalReceivable += amount * tx.type.receivableEffect;
    }

    if (savings < 0) savings = 0;
    if (totalDebt < 0) totalDebt = 0;
    if (totalReceivable < 0) totalReceivable = 0;
  }
}