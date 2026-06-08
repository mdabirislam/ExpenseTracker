import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';
import '../../models/transaction_model.dart';
import '../../models/transaction_type.dart';
import '../../utils/helpers.dart';
import '../screens/after_click_screen/edit_transaction_screen.dart';

class TransactionPreview extends StatelessWidget {
  final TransactionData tx;

  const TransactionPreview({super.key, required this.tx});

  void _deleteTransaction(BuildContext context) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Transaction"),
        content: const Text(
          "Are you sure you want to delete this transaction?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      tx.delete();
    }
  }

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
      }
    }();

    final String sign = tx.type.balanceEffect >= 0 ? '+' : '-';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.source,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  formatDate(tx.date),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),

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
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '$sign ৳ ${tx.amount.toStringAsFixed(2)}',
                    style: TextStyle(color: color, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 4),

                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert, size: 16),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text("Edit")),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text("Delete"),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'delete') {
                        _deleteTransaction(context);
                      }

                      if (value == 'edit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditTransactionScreen(tx: tx),
                          ),
                        );
                        // next step: open edit screen
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   const SnackBar(
                        //     content: Text("Edit system coming next"),
                        //   ),
                        // );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
