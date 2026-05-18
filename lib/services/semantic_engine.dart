import '../models/transaction_type.dart';

class SemanticEngine {

  // ================= VALID TYPES =================

  static final Map<String, TransactionType> validTypes = {

    'income': TransactionType.income,
    'expense': TransactionType.expense,

    'borrow': TransactionType.debtBorrow,
    'debtborrow': TransactionType.debtBorrow,

    'repay': TransactionType.debtRepay,
    'debtrepay': TransactionType.debtRepay,

    'lend': TransactionType.lendGive,
    'lendgive': TransactionType.lendGive,

    'receive': TransactionType.lendReceive,
    'lendreceive': TransactionType.lendReceive,
  };

  // ================= FUZZY TYPE =================

  static TransactionType? detectExplicitType(String raw) {

    final cleaned = raw
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z]'), '');

    if (cleaned.isEmpty) return null;

    if (validTypes.containsKey(cleaned)) {
      return validTypes[cleaned];
    }

    int bestScore = 999;
    TransactionType? bestType;

    for (final entry in validTypes.entries) {

      final score = _distance(cleaned, entry.key);

      if (score < bestScore) {
        bestScore = score;
        bestType = entry.value;
      }
    }

    if (bestScore <= 3) {
      return bestType;
    }

    return null;
  }

  // ================= AI TYPE GUESS =================

  static TransactionType guessType(String source) {

    final s = source.toLowerCase();

    if (s.contains('salary')) {
      return TransactionType.income;
    }

    if (s.contains('income')) {
      return TransactionType.income;
    }

    if (s.contains('gift')) {
      return TransactionType.income;
    }

    return TransactionType.expense;
  }

  // ================= CATEGORY =================

  static String guessCategory(
    String source,
    TransactionType type,
  ) {

    final s = source.toLowerCase();

    if (s.contains('iftar')) return 'Food';

    if (s.contains('food')) return 'Food';

    if (s.contains('market')) return 'Shopping';

    if (s.contains('bazar')) return 'kacha bazar';

    if (s.contains('cycle')) return 'Transport';

    if (s.contains('bus')) return 'Transport';

    if (s.contains('medicine')) return 'Health';

    if (type == TransactionType.income) {
      return 'Salary';
    }

    return 'Other';
  }

  // ================= LEVENSHTEIN =================

  static int _distance(String s, String t) {

    List<List<int>> dp = List.generate(
      s.length + 1,
      (_) => List.filled(t.length + 1, 0),
    );

    for (int i = 0; i <= s.length; i++) {
      dp[i][0] = i;
    }

    for (int j = 0; j <= t.length; j++) {
      dp[0][j] = j;
    }

    for (int i = 1; i <= s.length; i++) {

      for (int j = 1; j <= t.length; j++) {

        int cost = s[i - 1] == t[j - 1] ? 0 : 1;

        dp[i][j] = [
          dp[i - 1][j] + 1,
          dp[i][j - 1] + 1,
          dp[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return dp[s.length][t.length];
  }
}