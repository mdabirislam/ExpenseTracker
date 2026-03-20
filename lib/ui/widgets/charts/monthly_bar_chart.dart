import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../models/transaction_model.dart';
import '../../../models/transaction_type.dart';

class MonthlyBarChart extends StatefulWidget {
  final String title;

  const MonthlyBarChart({
    super.key,
    this.title = 'Monthly Expense Analysis',
  });

  @override
  State<MonthlyBarChart> createState() => _MonthlyBarChartState();
}

class _MonthlyBarChartState extends State<MonthlyBarChart> {

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {

    final box = Hive.box<TransactionData>('transactions');

    return ValueListenableBuilder(
      valueListenable: box.listenable(),
      builder: (context, Box<TransactionData> box, _) {

        final now = DateTime.now();

        DateTime? oldest;

        for (var tx in box.values) {
          if (tx.type != TransactionType.expense) continue;

          if (oldest == null || tx.date.isBefore(oldest)) {
            oldest = tx.date;
          }
        }

        int monthCount = 6;

        if (oldest != null) {
          monthCount =
              (now.year - oldest.year) * 12 +
              now.month -
              oldest.month +
              1;
        }

        final List<String> months = [];
        final Map<String, double> monthlyData = {};

        for (int i = 0; i < monthCount; i++) {

          final date = DateTime(now.year, now.month - i);

          final key = DateFormat('MMM yyyy').format(date);

          months.add(key);
          monthlyData[key] = 0;
        }

        for (var tx in box.values) {

          if (tx.type != TransactionType.expense) continue;

          final key = DateFormat('MMM yyyy').format(tx.date);

          if (monthlyData.containsKey(key)) {
            monthlyData[key] =
                (monthlyData[key] ?? 0) + tx.amount;
          }
        }

        final values = months.map((m) => monthlyData[m]!).toList();

        final double maxY = values.isEmpty
            ? 100.0
            : values.reduce((a, b) => a > b ? a : b) * 1.2;

        final double screenWidth = MediaQuery.of(context).size.width;
        final chartWidth =
            (months.length * 70).clamp(screenWidth, double.infinity).toDouble();

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),

                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  interactive: true,

                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,

                    child: SizedBox(
                      width: chartWidth,

                      child: BarChart(
                        BarChartData(
                          maxY: maxY,

                          barTouchData: BarTouchData(
                            enabled: true,
                            handleBuiltInTouches: true,
                          ),

                          gridData: FlGridData(show: true),
                          borderData: FlBorderData(show: false),

                          titlesData: FlTitlesData(

                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 35,
                                interval: (maxY / 5).clamp(1, double.infinity),
                              ),
                            ),

                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 1,
                                getTitlesWidget: (value, meta) {

                                  int index = value.toInt();

                                  if (index < months.length) {

                                    final month =
                                        months[index].split(" ")[0];

                                    return Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        month,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    );
                                  }

                                  return const Text('');
                                },
                              ),
                            ),

                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),

                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),

                          barGroups: List.generate(months.length, (index) {

                            return BarChartGroupData(
                              x: index,
                              barRods: [

                                BarChartRodData(
                                  toY: values[index],
                                  width: 18,
                                  borderRadius: BorderRadius.circular(4),
                                  color: index == 0
                                      ? Colors.blue
                                      : Colors.grey.shade400,
                                )

                              ],
                            );

                          }),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}