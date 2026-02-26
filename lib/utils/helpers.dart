import '../models/transaction_type.dart';

/// 🔹 TransactionType label with language support
String transactionTypeLabel(TransactionType type, {String lang = 'en'}) {
  switch (lang) {
    case 'bn':
      return _bnLabel(type);
    case 'en':
    default:
      return _enLabel(type);
  }
}

String _enLabel(TransactionType type) {
  switch (type) {
    case TransactionType.income:
      return 'Income';
    case TransactionType.expense:
      return 'Expense';
    case TransactionType.debtBorrow:
      return 'Borrow Money';
    case TransactionType.debtRepay:
      return 'Debt Repayment';
    case TransactionType.creditBuy:
      return 'Credit Purchase';
    case TransactionType.creditPay:
      return 'Credit Payment';
    case TransactionType.savingsAdd:
      return 'Add to Savings';
    case TransactionType.savingsWithdraw:
      return 'Withdraw from Savings';
    case TransactionType.lendGive:
      return 'Lend Money';
    case TransactionType.lendReceive:
      return 'Lend Repay';
  }
}

String _bnLabel(TransactionType type) {
  switch (type) {
    case TransactionType.income:
      return 'আয়';
    case TransactionType.expense:
      return 'খরচ';
    case TransactionType.debtBorrow:
      return 'ধার নেওয়া';
    case TransactionType.debtRepay:
      return 'ধার পরিশোধ';
    case TransactionType.creditBuy:
      return 'বাকি কেনা';
    case TransactionType.creditPay:
      return 'বাকি পরিশোধ';
    case TransactionType.savingsAdd:
      return 'সঞ্চয়ে যোগ';
    case TransactionType.savingsWithdraw:
      return 'সঞ্চয় থেকে নেওয়া';
    case TransactionType.lendGive:
      return 'ধার দেওয়া';
    case TransactionType.lendReceive:
      return 'ধার আদায়';
  }
}

/// 🔹 Format date as dd/mm/yyyy
String formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2,'0')}/${date.month.toString().padLeft(2,'0')}/${date.year}';
}

/// 🔹 Generate month key (YYYY-MM)
String generateMonthKey(DateTime date) {
  return '${date.year.toString().padLeft(4,'0')}-${date.month.toString().padLeft(2,'0')}';
}

/// 🔹 Generate unique source name
String generateUniqueSource(String source, List<String> existingSources) {
  if (!existingSources.contains(source)) return source;
  int i = 1;
  while (existingSources.contains('$source $i')) {
    i++;
  }
  return '$source $i';
}