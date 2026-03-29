import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../models/transaction_model.dart';
import '../../../models/transaction_type.dart';

class MonthlyLineChart extends StatefulWidget {
  final String title;

  const MonthlyLineChart({super.key, this.title = 'Monthly Analysis'});

  @override
  State<MonthlyLineChart> createState() => _MonthlyLineChartState();
}

class _MonthlyLineChartState extends State<MonthlyLineChart> {
  bool showAmount = false; // toggle to show/hide amount above dots

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<TransactionData>('transactions');

    return ValueListenableBuilder(
      valueListenable: box.listenable(),
      builder: (context, Box<TransactionData> box, _) {
        final now = DateTime.now();
        DateTime? oldest;

        for (var tx in box.values) {
          if (oldest == null || tx.date.isBefore(oldest)) {
            oldest = tx.date;
          }
        }

        int monthCount = 12;
        if (oldest != null) {
          monthCount =
              (now.year - oldest.year) * 12 + now.month - oldest.month + 1;
        }

        // Prepare months
        final List<DateTime> months = [];
        for (int i = monthCount - 1; i >= 0; i--) {
          months.add(DateTime(now.year, now.month - i));
        }

        // Prepare data maps
        final Map<String, double> incomeData = {};
        final Map<String, double> expenseData = {};

        for (var month in months) {
          final key = DateFormat('MMM yyyy').format(month);
          incomeData[key] = 0;
          expenseData[key] = 0;
        }

        for (var tx in box.values) {
          final key = DateFormat('MMM yyyy').format(tx.date);
          if (incomeData.containsKey(key)) {
            if (tx.type == TransactionType.income) {
              incomeData[key] = (incomeData[key]! + tx.amount);
            } else if (tx.type == TransactionType.expense) {
              expenseData[key] = (expenseData[key]! + tx.amount);
            }
          }
        }

        // Prepare FlSpot lists
        final List<FlSpot> incomeSpots = [];
        final List<FlSpot> expenseSpots = [];

        for (int i = 0; i < months.length; i++) {
          final key = DateFormat('MMM yyyy').format(months[i]);
          incomeSpots.add(FlSpot(i.toDouble(), incomeData[key]!));
          expenseSpots.add(FlSpot(i.toDouble(), expenseData[key]!));
        }

        // Determine max Y
        final double maxY =
            [
              ...incomeData.values,
              ...expenseData.values,
            ].fold(0.0, (prev, e) => e > prev ? e : prev) *
                1.2;

        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header legend and toggle
              Row(
                children: [
                  const Text('Income: '),
                  Container(width: 16, height: 16, color: Colors.green),
                  const SizedBox(width: 16),
                  const Text('Expense: '),
                  Container(width: 16, height: 16, color: Colors.red),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        showAmount = !showAmount;
                      });
                    },
                    child: Text(showAmount ? 'Hide Amount' : 'Show Amount'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Chart Container
              Container(
                constraints: const BoxConstraints(
                  maxHeight: 300, // max height for chart
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: maxY,
                      lineTouchData: LineTouchData(
                        handleBuiltInTouches: true,
                        touchTooltipData: LineTouchTooltipData(
                          tooltipRoundedRadius: 8,
                          tooltipPadding: const EdgeInsets.all(8),
                          getTooltipItems: (spots) {
                            return spots.map((spot) {
                              final month = DateFormat('MMM yyyy')
                                  .format(months[spot.x.toInt()]);
                              final type =
                                  spot.barIndex == 0 ? 'Income' : 'Expense';
                              return LineTooltipItem(
                                '$month\n$type: \$${spot.y.toStringAsFixed(2)}',
                                const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              int index = value.toInt();
                              if (index >= 0 && index < months.length) {
                                final month =
                                    DateFormat('MMM').format(months[index]);
                                final year = months[index].year;
                                bool showYear = index == 0 ||
                                    months[index].month == 1;
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        month,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    if (showYear)
                                      Flexible(
                                        child: Text(
                                          '$year',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                      ),
                      gridData: FlGridData(show: true),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: incomeSpots,
                          isCurved: true,
                          color: Colors.green,
                          barWidth: 3,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter:
                                (spot, percent, barData, index) =>
                                    FlDotCirclePainter(
                              radius: 4,
                              color: Colors.green,
                              strokeWidth: 0,
                            ),
                          ),
                          belowBarData: BarAreaData(show: false),
                        ),
                        LineChartBarData(
                          spots: expenseSpots,
                          isCurved: true,
                          color: Colors.red,
                          barWidth: 3,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter:
                                (spot, percent, barData, index) =>
                                    FlDotCirclePainter(
                              radius: 4,
                              color: Colors.red,
                              strokeWidth: 0,
                            ),
                          ),
                          belowBarData: BarAreaData(show: false),
                        ),
                      ],
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