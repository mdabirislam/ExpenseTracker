

String formatDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}

enum TransactionType {
  expense,
  income,
  debt,
}

String transactionTypeLabel(TransactionType type) {
  switch (type) {
    case TransactionType.expense:
      return 'Expense';
    case TransactionType.income:
      return 'Income';
    case TransactionType.debt:
      return 'Debt';
  }
}
//________generateUniqueSource________
String generateUniqueSource(String source,List<String> existingSources){
  if (!existingSources.contains(source)) return source;

  int i = 1;
  while (existingSources.contains('$source $i')) {
    i++;
  }
  return '$source $i';
}


  // ───────── Computed getters ─────────

