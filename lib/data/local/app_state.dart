import 'package:hive/hive.dart';
import '../../models/transaction_model.dart';
import '../../models/transaction_type.dart';
import '../../models/month_range_model.dart';

class AppState {
  static late Box<TransactionData> _txBox;
  static late Box<MonthRange> _monthBox;

  static double totalExpense = 0.0;
  static double totalIncome = 0.0;
  static double totalDebt = 0.0;
  static double totalLend = 0.0;
  static double totalReceivable = 0.0;
  static double savings = 0.0;
  static double balance = 0.0;

  /// 🔹 Initialize Hive boxes safely
  static Future<void> init() async {
    if (!Hive.isBoxOpen('transactions')) {
      _txBox = await Hive.openBox<TransactionData>('transactions');
    } else {
      _txBox = Hive.box<TransactionData>('transactions');
    }

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

  /// 🔹 Get currently active month range based on current date
  static MonthRange? getCurrentMonthRange() {
    final now = DateTime.now();

    for (final item in _monthBox.values) {
      if (!item.start.isAfter(now) && !item.end.isBefore(now)) {
        return item;
      }
    }
    return null;
  }

  /// 🔹 Get remaining days of current month range
  static int? getRemainingDays() {
    final current = getCurrentMonthRange();
    if (current == null) return null;

    final now = DateTime.now();
    final remaining = current.end.difference(now).inDays;
    return remaining >= 0 ? remaining + 1 : 0; // include today
  }

  /// 🔹 Add new month range
  static Future<void> addMonthRange({
    required DateTime start,
    required DateTime end,
    required String monthName,
  }) async {
    final monthRange = MonthRange(start: start, end: end, monthName: monthName);
    await _monthBox.add(monthRange);
  }

  /// 🔹 Add transaction
  static Future<void> addTransaction(TransactionData tx) async {
    if (tx.type == TransactionType.savingsWithdraw && tx.amount > savings) {
      throw Exception('Cannot withdraw more than available savings: $savings');
    }
    await _txBox.add(tx);
    recalculateFromBox();
  }

  static List<TransactionData> get transactions =>
      _txBox.values.toList().reversed.toList();

  /// 🔹 Recalculate all totals
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