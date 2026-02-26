import 'package:flutter/material.dart';
import '../../models/transaction_model.dart';
import '../../utils/helpers.dart';
import '../../models/transaction_type.dart';

class TransactionPreview extends StatelessWidget {
  final TransactionData tx;

  const TransactionPreview({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    final type = tx.type;

    // color according to type
    final Color color = () {
      switch (type) {
        case TransactionType.income:
          return Colors.green;
        case TransactionType.expense:
          return Colors.red;
        case TransactionType.debtBorrow:
        case TransactionType.debtRepay:
        case TransactionType.creditBuy:
        case TransactionType.creditPay:
          return Colors.orange;
        case TransactionType.savingsAdd:
        case TransactionType.savingsWithdraw:
          return Colors.purple;
        default:
          return Colors.blue;
      }
    }();

    // icon according to type
    final IconData icon = () {
      switch (type) {
        case TransactionType.income:
          return Icons.arrow_downward;
        case TransactionType.expense:
          return Icons.arrow_upward;
        case TransactionType.debtBorrow:
          return Icons.call_received;
        case TransactionType.debtRepay:
          return Icons.payments;
        case TransactionType.creditBuy:
          return Icons.shopping_cart;
        case TransactionType.creditPay:
          return Icons.payment;
        case TransactionType.savingsAdd:
          return Icons.savings;
        case TransactionType.savingsWithdraw:
          return Icons.money_off;
        default:
          return Icons.help_outline;
      }
    }();

    // sign according to balance effect
    final String sign = tx.type.balanceEffect >= 0 ? '+' : '-';

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
            formatDate(tx.date),
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
        '$sign ৳ ${tx.amount.toStringAsFixed(2)}',
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}