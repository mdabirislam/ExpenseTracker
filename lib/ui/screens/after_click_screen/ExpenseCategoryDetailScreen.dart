import 'package:flutter/material.dart';
import '../../../data/local/app_state.dart';
import '../../../models/transaction_type.dart';
import '../../../models/transaction_model.dart';

class CategoryExpenseScreen extends StatelessWidget {
  final String category;
  final DateTimeRange range;

  const CategoryExpenseScreen({
    super.key,
    required this.category,
    required this.range,
  });

  List<TransactionData> getFiltered() {
    return AppState.transactions.where((tx) {
      return tx.type == TransactionType.expense &&
          tx.category == category &&
          !tx.date.isBefore(range.start) &&
          !tx.date.isAfter(range.end);
    }).toList();
  }

  String formatDate(DateTime d) => "${d.day}/${d.month}/${d.year}";

  @override
  Widget build(BuildContext context) {
    final data = getFiltered();

    final total = data.fold<double>(0, (sum, tx) => sum + tx.amount);

    return Scaffold(
      appBar: AppBar(title: Text(category), backgroundColor: Colors.green),

      body: Column(
        children: [
          // ?? Top Summary
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.green,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Total: ৳ ${total.toStringAsFixed(2)}",
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  "${formatDate(range.start)} - ${formatDate(range.end)}",
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // ?? Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: Colors.grey[300],
            child: Row(
              children: const [
                Expanded(flex: 4, child: Text('Source')),
                Expanded(
                  flex: 3,
                  child: Text('Date', textAlign: TextAlign.center),
                ),
                Expanded(
                  flex: 3,
                  child: Text('Amount', textAlign: TextAlign.end),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // ?? List
          Expanded(
            child: data.isEmpty
                ? const Center(child: Text('No Data'))
                : ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final tx = data[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            // Source / Label
                            Expanded(
                              flex: 4,
                              child: Text(
                                tx.source ?? 'Unknown',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            // Date
                            Expanded(
                              flex: 3,
                              child: Text(
                                formatDate(tx.date),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            // Amount
                            Expanded(
                              flex: 3,
                              child: Text(
                                "৳ ${tx.amount.toStringAsFixed(2)}",
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
