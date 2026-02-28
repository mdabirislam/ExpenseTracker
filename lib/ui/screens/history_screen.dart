import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/transaction_model.dart';
import '../widgets/transaction_preview.dart';

enum HistoryRange { today, week, month, all }

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  HistoryRange selectedRange = HistoryRange.week;

  DateTime now = DateTime.now();

  bool _matchRange(TransactionData tx) {
    final date = tx.date;

    switch (selectedRange) {
      case HistoryRange.today:
        return date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;

      case HistoryRange.week:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        return date.isAfter(startOfWeek.subtract(const Duration(days: 1)));

      case HistoryRange.month:
        return date.year == now.year && date.month == now.month;

      case HistoryRange.all:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: Column(
        children: [
          _rangeSelector(),
          const SizedBox(height: 8),
          _searchFilterSection(),
          const SizedBox(height: 8),
          Expanded(child: _transactionList()),
        ],
      ),
    );
  }

  Widget _rangeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          _chip("Today", HistoryRange.today),
          _chip("Week", HistoryRange.week),
          _chip("Month", HistoryRange.month),
          _chip("All", HistoryRange.all),
        ],
      ),
    );
  }

  Widget _chip(String label, HistoryRange range) {
    final selected = selectedRange == range;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          setState(() {
            selectedRange = range;
          });
        },
      ),
    );
  }

  Widget _searchFilterSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search source...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () {
              // future filter system
            },
          ),
        ],
      ),
    );
  }

  Widget _transactionList() {
    return ValueListenableBuilder(
      valueListenable: Hive.box<TransactionData>('transactions').listenable(),
      builder: (context, Box<TransactionData> box, _) {
        final transactions = box.values
            .where(_matchRange)
            .toList()
            .reversed
            .toList();

        if (transactions.isEmpty) {
          return const Center(
            child: Text("No transactions found"),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: transactions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) =>
              TransactionPreview(tx: transactions[index]),
        );
      },
    );
  }
}