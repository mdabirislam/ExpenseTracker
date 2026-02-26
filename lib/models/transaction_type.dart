//__________for automatic making of ....g.dart_______
// flutter packages pub run build_runner build --delete-conflicting-outputs

import 'package:hive/hive.dart';
part 'transaction_type.g.dart';

@HiveType(typeId: 2)
enum TransactionType {
  @HiveField(0) income,
  @HiveField(1) expense,
  @HiveField(2) debtBorrow,   // I borrowed money → balance +, debt +
  @HiveField(3) debtRepay,    // I repay debt → balance -, debt -
  @HiveField(4) creditBuy,    // Bought on credit → balance 0, debt +
  @HiveField(5) creditPay,    // Pay credit → balance -, debt -
  @HiveField(6) savingsAdd,      // balance -> savings
  @HiveField(7) savingsWithdraw, // savings -> balance
  @HiveField(8) lendGive,     // I lend someone → balance -, receivable +
  @HiveField(9) lendReceive;  // Someone pays me → balance +, receivable -

  /// 🔹 Balance effect
  int get balanceEffect {
    switch (this) {
      case TransactionType.income:
      case TransactionType.debtBorrow:
      case TransactionType.savingsWithdraw:
      case TransactionType.lendReceive:
        return 1;
      case TransactionType.expense:
      case TransactionType.debtRepay:
      case TransactionType.creditPay:
      case TransactionType.savingsAdd:
      case TransactionType.lendGive:
        return -1;
      case TransactionType.creditBuy:
        return 0;
    }
  }

  /// 🔹 Debt effect
  int get debtEffect {
    switch (this) {
      case TransactionType.debtBorrow:
      case TransactionType.creditBuy:
        return 1;
      case TransactionType.debtRepay:
      case TransactionType.creditPay:
        return -1;
      default:
        return 0;
    }
  }

  /// 🔹 Savings effect
  int get savingsEffect {
    switch (this) {
      case TransactionType.savingsAdd:
        return 1;
      case TransactionType.savingsWithdraw:
        return -1;
      default:
        return 0;
    }
  }

  /// 🔹 Receivable effect (lend)
  int get receivableEffect {
    switch (this) {
      case TransactionType.lendGive:
        return 1;
      case TransactionType.lendReceive:
        return -1;
      default:
        return 0;
    }
  }

  /// 🔹 Label
  String get label {
    switch (this) {
      case TransactionType.income:
        return 'Income';
      case TransactionType.expense:
        return 'Expense';
      case TransactionType.debtBorrow:
        return 'Debt Borrow';
      case TransactionType.debtRepay:
        return 'Debt Repay';
      case TransactionType.creditBuy:
        return 'Credit Buy';
      case TransactionType.creditPay:
        return 'Credit Pay';
      case TransactionType.savingsAdd:
        return 'Add to Savings';
      case TransactionType.savingsWithdraw:
        return 'Withdraw Savings';
      case TransactionType.lendGive:
        return 'Lend';
      case TransactionType.lendReceive:
        return 'Lend Repay';
    }
  }
}