import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../models/transaction_model.dart';
import '../../../models/transaction_type.dart';

class CategoryPieChart extends StatefulWidget {
  const CategoryPieChart({super.key});

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  TransactionType _selectedType = TransactionType.expense;

  Map<String, double> _calculateCategoryTotals(
      List<TransactionData> txs, TransactionType type) {
    final Map<String, double> totals = {};

    for (var tx in txs) {
      if (tx.type != type) continue;
      if (tx.amount <= 0) continue;

      totals[tx.category] = (totals[tx.category] ?? 0) + tx.amount;
    }

    return totals;
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<TransactionData>('transactions');

    return ValueListenableBuilder(
      valueListenable: box.listenable(),
      builder: (context, Box<TransactionData> box, _) {
        final transactions = box.values.toList();

        final categoryTotals =
            _calculateCategoryTotals(transactions, _selectedType);

        final sections = categoryTotals.entries.map((entry) {
          return PieChartSectionData(
            value: entry.value,
            title: entry.key,
            radius: 60,
          );
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header + Filter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Category Analysis",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                DropdownButton<TransactionType>(
                  value: _selectedType,
                  onChanged: (val) {
                    setState(() {
                      _selectedType = val!;
                    });
                  },
                  items: TransactionType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.name),
                    );
                  }).toList(),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// Chart Area
            SizedBox(
              height: 220,
              child: categoryTotals.isEmpty
                  ? const Center(
                      child: Text(
                        "No transactions for this type yet",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : PieChart(
                      PieChartData(
                        sections: sections,
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}