import 'package:hive/hive.dart';
import '../../models/transaction_model.dart';
import '../../models/transaction_type.dart';
import '../../models/month_range_model.dart';
import '../../models/monthly_summary_model.dart';

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
    await _initMonths();
    _recalculateGlobal();
  }

  static Future<void> _initMonths() async {
    if (!Hive.isBoxOpen('monthRanges')) {
      _monthBox = await Hive.openBox<MonthRange>('monthRanges');
    } else {
      _monthBox = Hive.box<MonthRange>('monthRanges');
    }
  }

  // ================== MONTH RANGE ==================
  static Future<void> saveMonth(MonthRange range) async {
    final index = _monthBox.values.toList().indexWhere((m) =>
        m.monthRef.year == range.monthRef.year &&
        m.monthRef.month == range.monthRef.month);

    if (index != -1) {
      await _monthBox.putAt(index, range);
    } else {
      await _monthBox.add(range);
    }
  }
static MonthRange? getCurrentMonthRange() {
  final now = DateTime.now();

  try {
    return _monthBox.values.firstWhere((m) =>
        !now.isBefore(m.start) && !now.isAfter(m.end));
  } catch (_) {
    return null;
  }
}
static MonthRange? getMonth(DateTime input) {
  // 🔥 1. Check by date range (MOST IMPORTANT)
  for (final m in _monthBox.values) {
    if (!input.isBefore(m.start) && !input.isAfter(m.end)) {
      return m;
    }
  }

  // 🔥 2. fallback: monthRef match
  for (final m in _monthBox.values) {
    if (m.monthRef.year == input.year &&
        m.monthRef.month == input.month) {
      return m;
    }
  }

  return null;
}

  static List<MonthRange> get allMonths => _monthBox.values.toList();

  // ================== TRANSACTIONS ==================
  static Future<void> addTransaction(TransactionData tx) async {
    if (tx.type == TransactionType.savingsWithdraw && tx.amount > savings) {
      throw Exception('Cannot withdraw more than available savings: $savings');
    }

    await _txBox.add(tx);

    // ✅ update global totals fast
    _recalculateGlobal();
  }

  static List<TransactionData> get transactions => _txBox.values.toList().reversed.toList();

  // ================== GLOBAL CALCULATION ==================
  static void _recalculateGlobal() {
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
      totalLend += amount * (tx.type == TransactionType.lendGive || tx.type == TransactionType.lendReceive ? 1 : 0);
    }

    if (savings < 0) savings = 0;
    if (totalDebt < 0) totalDebt = 0;
    if (totalReceivable < 0) totalReceivable = 0;
    if (totalLend < 0) totalLend = 0;
  }

  // ================== FILTERED TRANSACTIONS ==================
  static List<TransactionData> _getTransactionsByRange(DateTime start, DateTime end) {
    return _txBox.values.where((tx) {
      if (tx.isPlanned) return false;
      return !tx.date.isBefore(start) && !tx.date.isAfter(end);
    }).toList();
  }

// ================== MONTHLY CALCULATION ==================
static MonthlySummary calculateByRange(DateTime startDate, DateTime endDate) {
  double income = 0;
  double expense = 0;
  double debt = 0;
  double savingsVal = 0;
  double balanceVal = 0;
  double lendVal = 0;
  double borrowVal = 0; // <-- monthly borrow

  final filtered = _getTransactionsByRange(startDate, endDate);

  for (final tx in filtered) {
    final amount = tx.amount;

    if (tx.type == TransactionType.income) income += amount;
    if (tx.type == TransactionType.expense) expense += amount;

    balanceVal += amount * tx.type.balanceEffect;
    debt += amount * tx.type.debtEffect;
    savingsVal += amount * tx.type.savingsEffect;

    // ✅ monthly lend
    lendVal += amount * tx.type.receivableEffect;

    // ✅ monthly borrow
    if (tx.type == TransactionType.debtBorrow) borrowVal += amount;
  }

  return MonthlySummary(
    income: income,
    expense: expense,
    debt: debt < 0 ? 0 : debt,
    savings: savingsVal < 0 ? 0 : savingsVal,
    balance: balanceVal,
    lend: lendVal < 0 ? 0 : lendVal,
    borrow: borrowVal < 0 ? 0 : borrowVal, // <-- return borrow
  );
}
  // ================== CURRENT MONTH ==================
  static MonthlySummary getCurrentMonthSummary() {
    final range = getCurrentMonthRange();

    if (range == null) {
      return MonthlySummary(
        income: 0,
        expense: 0,
        debt: 0,
        savings: 0,
        balance: 0,
        lend: 0,
        borrow: 0,
      );
    }

    return calculateByRange(range.start, range.end);
  }
}