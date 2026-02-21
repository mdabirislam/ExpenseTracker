import 'package:hive/hive.dart';
import '../../models/transaction_model.dart';
import '../../utils/helpers.dart';
import '../../models/transaction_type.dart';

class TransactionService {
  static Box<TransactionData> get _box =>
      Hive.box<TransactionData>('transactions');

  /// 🔹 Get all existing sources (by type)
  static List<String> getSourcesByType(TransactionType type) {
    return _box.values
        .where((tx) => tx.type == type)
        .map((tx) => tx.source)
        .toSet()
        .toList();
  }

  /// 🔹 Handle source logic
  static String resolveSource({
    required TransactionType type,
    required String inputSource,
    required bool mergeWithExisting,
  }) {
    final existingSources = getSourcesByType(type);

    if (!existingSources.contains(inputSource)) {
      return inputSource;
    }

    if (mergeWithExisting) {
      return inputSource; // same source
    }

    // rename
    return generateUniqueSource(inputSource, existingSources);
  }

  /// 🔹 Save transaction
  static Future<void> save(TransactionData tx) async {
    await _box.add(tx);
  }
}
