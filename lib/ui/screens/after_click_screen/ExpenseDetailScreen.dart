import 'package:flutter/material.dart';
import '../../../data/local/app_state.dart';
import '../../../models/transaction_type.dart';
import '../menu_screen.dart';

class ExpenseDetailScreen extends StatefulWidget {
  const ExpenseDetailScreen({super.key});

  @override
  State<ExpenseDetailScreen> createState() => _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends State<ExpenseDetailScreen> {
  String? selectedMonth;
  bool isAllTime = false;

  List<DateTime> availableMonths = [];

  @override
  void initState() {
    super.initState();
    _prepareMonths();
  }

  void _prepareMonths() {
    final tx = AppState.transactions;

    final monthsSet = <String>{};
    for (var t in tx) {
      monthsSet.add("${t.date.year}-${t.date.month}");
    }

    availableMonths = monthsSet.map((e) {
      final parts = e.split('-');
      return DateTime(int.parse(parts[0]), int.parse(parts[1]));
    }).toList()
      ..sort((a, b) => b.compareTo(a));

    final now = DateTime.now();
    final currentKey = "${now.year}-${now.month}";

    if (monthsSet.contains(currentKey)) {
      selectedMonth = currentKey;
    } else if (availableMonths.isNotEmpty) {
      final lastMonth = availableMonths.first;
      selectedMonth = "${lastMonth.year}-${lastMonth.month}";
    } else {
      selectedMonth = null;
    }
  }

  bool get isCurrentMonthAvailable {
    final now = DateTime.now();
    return availableMonths.any((m) => m.year == now.year && m.month == now.month);
  }

  DateTimeRange getRange() {
    final tx = AppState.transactions;

    if (isAllTime) {
      if (tx.isEmpty) {
        final now = DateTime.now();
        return DateTimeRange(start: now, end: now);
      }
      final sorted = [...tx]..sort((a, b) => a.date.compareTo(b.date));
      return DateTimeRange(start: sorted.first.date, end: sorted.last.date);
    }

    if (selectedMonth == null) {
      return DateTimeRange(start: DateTime.now(), end: DateTime.now());
    }

    final parts = selectedMonth!.split('-');
    final y = int.parse(parts[0]);
    final m = int.parse(parts[1]);

    return DateTimeRange(start: DateTime(y, m, 1), end: DateTime(y, m + 1, 0));
  }

  List getFiltered() {
    final range = getRange();
    return AppState.transactions.where((tx) {
      return !tx.date.isBefore(range.start) && !tx.date.isAfter(range.end);
    }).toList();
  }

  Map<String, Map<String, dynamic>> groupByCategory(List txList) {
    final Map<String, Map<String, dynamic>> data = {};
    for (var tx in txList) {
      if (tx.type != TransactionType.expense) continue;
      final cat = tx.category ?? 'Others';
      data.putIfAbsent(cat, () => {'count': 0, 'amount': 0.0});
      data[cat]!['count'] += 1;
      data[cat]!['amount'] += tx.amount;
    }
    return data;
  }

  String formatDate(DateTime d) => "${d.day}/${d.month}/${d.year}";

  String formatMonth(DateTime m) {
    const names = [
      "Jan","Feb","Mar","Apr","May","Jun",
      "Jul","Aug","Sep","Oct","Nov","Dec"
    ];
    return "${names[m.month - 1]} ${m.year}";
  }

  void _showMonthPicker() {
    if (availableMonths.isEmpty) return;

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return ListView.builder(
          itemCount: availableMonths.length,
          itemBuilder: (context, index) {
            final m = availableMonths[index];
            final key = "${m.year}-${m.month}";
            return ListTile(
              title: Text(formatMonth(m)),
              onTap: () {
                setState(() {
                  selectedMonth = key;
                  isAllTime = false;
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = getFiltered();
    final grouped = groupByCategory(filtered);
    final categories = grouped.keys.toList();
    final total = grouped.values.fold<double>(0, (sum, e) => sum + e['amount']);
    final range = getRange();

    String monthDisplay;
    if (isAllTime) {
      monthDisplay = "All Time";
    } else if (selectedMonth != null) {
      final parts = selectedMonth!.split('-');
      final y = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      monthDisplay = formatMonth(DateTime(y, m));
    } else {
      monthDisplay = "No Month";
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Details'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [

          // 🔹 FILTER BAR
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.green,
            child: Row(
              children: [

                // Month Button LEFT
                if (availableMonths.isNotEmpty)
                  TextButton(
                    onPressed: _showMonthPicker,
                    child: Text(
                      monthDisplay,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  )
                else
                  Text(
                    monthDisplay,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),

                const Spacer(),

                // Range CENTER
                Text(
                  "${formatDate(range.start)} - ${formatDate(range.end)}",
                  style: const TextStyle(color: Colors.white),
                ),

                const Spacer(),

                // All Time RIGHT
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

          // ⚠️ Warning
          if (!isCurrentMonthAvailable)
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

          // Summary + Details
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
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    'Show Details',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // List
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
                        leading: Text(item['count'].toString()),
                        trailing: Text("৳ ${(item['amount'] as double).toStringAsFixed(2)}"),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}