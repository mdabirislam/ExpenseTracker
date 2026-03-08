import 'package:hive_flutter/hive_flutter.dart';
import '../../models/transaction_type.dart';

class CategoryManager {
  static late Box<List<dynamic>> _box;

  // Default demo categories
  static final Map<String, List<String>> _defaultGroups = {
    'income': ['Salary', 'Business', 'Bonus', 'Other'],
    'expense': ['Food', 'Transport', 'Shopping', 'Other'],
    'debt': ['Borrow', 'Loan', 'Debt Repay', 'Other'],
    'lend': ['Lend', 'Receive Back', 'Other'],
  };

  // In-memory cache
  static final Map<TransactionType, List<String>> _cache = {};

  /// Initialize Hive box
  static Future<void> init() async {
    _box = await Hive.openBox<List<dynamic>>('transaction_categories');

    for (var type in TransactionType.values) {
      final key = type.toString();
      final group = _groupOf(type);
      final saved = _box.get(key);

      if (saved == null) {
        _cache[type] = List<String>.from(_defaultGroups[group]!);
        await _box.put(key, _cache[type]!);
      } else {
        _cache[type] = List<String>.from(saved);
      }
    }
  }

  static List<String> getCategories(TransactionType type) {
    return _cache[type] ?? [];
  }

  static Future<void> addCategory(TransactionType type, String name) async {
    final list = _cache[type] ?? [];
    if (!list.any((c) => c.toLowerCase() == name.toLowerCase())) {
      list.add(name);
      _cache[type] = list;
      await _box.put(type.toString(), list);
    }
  }

  static String _groupOf(TransactionType type) {
    if (type == TransactionType.income) return 'income';
    if (type == TransactionType.expense) return 'expense';

    if (type == TransactionType.debtBorrow ||
        type == TransactionType.debtRepay ||
        type == TransactionType.creditBuy ||
        type == TransactionType.creditPay) return 'debt';

    if (type == TransactionType.lendGive || type == TransactionType.lendReceive)
      return 'lend';

    return 'expense';
  }
}