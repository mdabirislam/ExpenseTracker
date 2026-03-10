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
    List<TransactionData> txs,
    TransactionType type,
  ) {
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

        final categoryTotals = _calculateCategoryTotals(
          transactions,
          _selectedType,
        );
        final colors = [
          Colors.orange,
          Colors.blue,
          Colors.green,
          Colors.purple,
          Colors.deepOrangeAccent,
          Colors.teal,
          Colors.redAccent,
          Colors.pinkAccent,
          Colors.grey,
          ];
        final sections = categoryTotals.entries.toList().asMap().entries.map((
          entry,
        ) {
          final idx = entry.key; // index
          final e = entry.value; // MapEntry<String, double>
          return PieChartSectionData(
            value: e.value,
            title:
                "${((e.value / categoryTotals.values.reduce((a, b) => a + b)) * 100).toStringAsFixed(0)}%",
            radius: 60,
            color: colors[idx % colors.length],
            titleStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
            // Row(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            // ` children: [],
            // )
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: BorderSide.strokeAlignOutside,
              children: [
                const SizedBox(height: 12),
                /// Chart Area
                SizedBox(
                  height: 220,
                  width: 250,
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
                const SizedBox(width: 60),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: categoryTotals.entries.toList().asMap().entries.map(
                    (entry) {
                      final idx = entry.key;
                      final e = entry.value;
                      return Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            color: colors[idx % colors.length],
                          ),
                          const SizedBox(width: 6),
                          Text(e.key),
                        ],
                      );
                    },
                  ).toList(), //map
                ),
              ],
            ),
          ], //children
        );
      }, //Builder
    );
  }
}
