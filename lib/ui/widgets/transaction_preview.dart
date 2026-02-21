import 'package:flutter/material.dart';
import '../../models/transaction_model.dart';
import '../../utils/helpers.dart';
import '../../models/transaction_type.dart';

class TransactionPreview extends StatelessWidget {
  final TransactionData tx;

  const TransactionPreview({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    final isExpense = tx.type == TransactionType.expense;
    final isIncome = tx.type == TransactionType.income;
    final isDebt = tx.type == TransactionType.debt;

    final Color color =
          isExpense
        ? Colors.red
        : isIncome
        ? Colors.green
        : isDebt
        ? Colors.orange
        : Colors.blue;

    final IconData icon =
          isExpense
        ? Icons.arrow_upward
        : isIncome
        ? Icons.arrow_downward
        :isDebt
        ?Icons.arrow_downward
        : Icons.compare_arrows;

    return ListTile(
      contentPadding: EdgeInsets.zero,

      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.15),
        child: Icon(icon, color: color),
      ),

      title: Text(
        tx.source,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),

      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formatDate(tx.date), // helper.dart
            style: const TextStyle(fontSize: 12),
          ),
          if (tx.note != null && tx.note!.isNotEmpty)
            Text(
              tx.note!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
        ],
      ),

      trailing: Text(
        '${isExpense ? '-' : '+'} ৳ ${tx.amount.toStringAsFixed(2)}',
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
