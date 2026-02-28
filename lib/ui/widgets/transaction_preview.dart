import 'package:flutter/material.dart';
import '../../models/transaction_model.dart';
import '../../models/transaction_type.dart';
import '../../utils/helpers.dart';

class TransactionPreview extends StatelessWidget {
  final TransactionData tx;

  const TransactionPreview({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    final type = tx.type;

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
        case TransactionType.lendGive:
        case TransactionType.lendReceive:
          return Colors.blue;
        default:
          return Colors.grey;
      }
    }();

    final String sign = tx.type.balanceEffect >= 0 ? '+' : '-';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      child: Row(
        children: [
          // LEFT SIDE (Source + Date)
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.source,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  formatDate(tx.date),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // MIDDLE (Type + Category)
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  transactionTypeLabel(tx.type),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  tx.category,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // RIGHT SIDE (Amount)
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$sign ৳ ${tx.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}