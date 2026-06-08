import 'package:flutter/material.dart';
import '../../../data/local/app_state.dart';
import '../../../models/transaction_type.dart';
import '../menu_screen.dart';
import 'ExpenseCategoryDetailScreen.dart';

class ExpenseDetailScreen extends StatefulWidget {
  const ExpenseDetailScreen({super.key});

  @override
  State<ExpenseDetailScreen> createState() => _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends State<ExpenseDetailScreen> {
  bool isAllTime = false;

  // ================= RANGE =================
  DateTimeRange getRange() {
    final tx = AppState.transactions;

    // 🔥 ALL TIME
    if (isAllTime) {
      if (tx.isEmpty) {
        final now = DateTime.now();
        return DateTimeRange(start: now, end: now);
      }

      final sorted = [...tx]..sort((a, b) => a.date.compareTo(b.date));

      return DateTimeRange(
        start: sorted.first.date,
        end: sorted.last.date,
      );
    }

    // 🔥 CURRENT MONTH FROM APPSTATE (IMPORTANT CHANGE)
    final monthRange = AppState.getCurrentMonthRange();

    if (monthRange == null) {
      final now = DateTime.now();
      return DateTimeRange(start: now, end: now);
    }

    return DateTimeRange(
      start: monthRange.start,
      end: monthRange.end,
    );
  }

  // ================= FILTER =================
  List getFiltered() {
    final range = getRange();

    return AppState.transactions.where((tx) {
      return !tx.date.isBefore(range.start) &&
          !tx.date.isAfter(range.end);
    }).toList();
  }

  // ================= GROUP =================
  Map<String, Map<String, num>> groupByCategory(List txList) {
    final Map<String, Map<String, num>> data = {};

    for (var tx in txList) {
      if (tx.type != TransactionType.expense) continue;

      final cat = tx.category ?? 'Others';

      data.putIfAbsent(cat, () => {'count': 0, 'amount': 0});

      data[cat]!['count'] = (data[cat]!['count'] ?? 0) + 1;
      data[cat]!['amount'] = (data[cat]!['amount'] ?? 0) + tx.amount;
    }

    return data;
  }

  // ================= UI HELPERS =================
  String formatDate(DateTime d) => "${d.day}/${d.month}/${d.year}";

  String get monthDisplay {
    if (isAllTime) return "All Time";

    final range = AppState.getCurrentMonthRange();

    if (range == null) return "Not Set";

    return "${range.monthRef.month}/${range.monthRef.year}";
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    final filtered = getFiltered();
    final grouped = groupByCategory(filtered);
    final categories = grouped.keys.toList();

    final total = grouped.values.fold<double>(
      0,
      (sum, e) => sum + (e['amount'] ?? 0).toDouble(),
    );

    final range = getRange();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Details'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),

      body: Column(
        children: [

          // ================= FILTER BAR =================
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.green,
            child: Row(
              children: [

                Text(
                  monthDisplay,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),

                const Spacer(),

                Text(
                  "${formatDate(range.start)} - ${formatDate(range.end)}",
                  style: const TextStyle(color: Colors.white),
                ),

                const Spacer(),

                GestureDetector(
                  onTap: () {
                    setState(() {
                      isAllTime = true;
                    });
                  },
                  child: Text(
                    'All Time',
                    style: TextStyle(
                      color: isAllTime ? Colors.yellow : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ================= WARNING =================
          if (AppState.getCurrentMonthRange() == null)
            Container(
              width: double.infinity,
              color: Colors.orange,
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Please set current month!",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MenuScreen(),
                        ),
                      );
                    },
                    child: const Text('Set'),
                  )
                ],
              ),
            ),

          // ================= TOTAL =================
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Total Expense: ৳ ${total.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // ================= LIST =================
          Expanded(
            child: categories.isEmpty
                ? const Center(child: Text('No Data'))
                : ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final item = grouped[cat]!;

                      return ListTile(
                        title: Text(cat),
                        leading: Text((item['count'] ?? 0).toString()),
                        trailing: Text(
                          "৳ ${(item['amount'] ?? 0).toStringAsFixed(2)}",
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CategoryExpenseScreen(
                                category: cat,
                                range: getRange(),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}