class MonthlySummary {
  final double income;
  final double expense;
  final double debt;
  final double savings;
  final double balance;
  final double lend;
  final double borrow; // <-- new

  MonthlySummary({
    required this.income,
    required this.expense,
    required this.debt,
    required this.savings,
    required this.balance,
    required this.lend,
    required this.borrow, // <-- new
  });
}