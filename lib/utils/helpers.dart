import '../models/transaction_type.dart';

// TransactionType label with short, user-friendly names
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
      return 'Income Money';
    case TransactionType.expense:
      return 'Expense Money';
    case TransactionType.debtBorrow:
      return 'Debt to Pay';
    case TransactionType.debtRepay:
      return 'Repaid Debt';
    case TransactionType.creditBuy:
      return 'Credit Buy';
    case TransactionType.creditPay:
      return 'Credit Paid';
    case TransactionType.savingsAdd:
      return 'Savings';
    case TransactionType.savingsWithdraw:
      return 'Withdraw Savings';
    case TransactionType.lendGive:
      return 'Lend Money';
    case TransactionType.lendReceive:
      return 'Repaid Lend';
  }
}

// Bangla version (optional)
String _bnLabel(TransactionType type) {
  switch (type) {
    case TransactionType.income:
      return 'আয়';
    case TransactionType.expense:
      return 'খরচ';
    case TransactionType.debtBorrow:
      return 'ধার';
    case TransactionType.debtRepay:
      return 'ধার পরিশোধ';
    case TransactionType.creditBuy:
      return 'বাকি কেনা';
    case TransactionType.creditPay:
      return 'বাকি পরিশোধ';
    case TransactionType.savingsAdd:
      return 'সঞ্চয়';
    case TransactionType.savingsWithdraw:
      return 'সঞ্চয় থেকে নেওয়া';
    case TransactionType.lendGive:
      return 'ধার দেওয়া';
    case TransactionType.lendReceive:
      return 'ধার ফেরত';
  }
}

/// 🔹 Format date as dd/mm/yyyy
String formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

/// 🔹 Generate month key (YYYY-MM)
String generateMonthKey(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}';
}

// /// 🔹 Generate unique source name
// we have unique id so we dont need this thing
// String generateUniqueSource(String source, List<String> existingSources) {
//   if (!existingSources.contains(source)) return source;
//   int i = 1;
//   while (existingSources.contains('$source $i')) {
//     i++;
//   }
//   return '$source $i';
// }
