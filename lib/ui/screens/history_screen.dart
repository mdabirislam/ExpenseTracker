import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../models/transaction_model.dart';
import '../../models/transaction_type.dart';
import '../../utils/helpers.dart';

import '../widgets/transaction_preview.dart';

enum HistoryRange { today, week, month, all }

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  HistoryRange selectedRange = HistoryRange.all;
  String _getDateLabel(DateTime date) {
  final today = DateTime.now();
  final yesterday = today.subtract(const Duration(days: 1));

  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year &&
      a.month == b.month &&
      a.day == b.day;

  if (isSameDay(date, today)) return "Today";
  if (isSameDay(date, yesterday)) return "Yesterday";

  return formatDate(date);
}
  String searchQuery = '';
  String selectedType = 'All';
  String sortType = 'Newest';

  final DateTime now = DateTime.now();

  // ================= GROUP SOURCE OF TRUTH =================
  final Map<String, List<TransactionType>> transactionGroups = {
    'Income': [TransactionType.income],
    'Expense': [TransactionType.expense],
    'Debt': [
      TransactionType.debtBorrow,
      TransactionType.debtRepay,
    ],
    'Credit': [
      TransactionType.creditBuy,
      TransactionType.creditPay,
    ],
    'Savings': [
      TransactionType.savingsAdd,
      TransactionType.savingsWithdraw,
    ],
    'Lend': [
      TransactionType.lendGive,
      TransactionType.lendReceive,
    ],
  };

  // ================= AUTO FILTER TYPES =================
  List<String> get filterTypes =>
      ['All', ...transactionGroups.keys];

  // ================= RANGE FILTER =================
  bool _matchRange(TransactionData tx) {
    final date = tx.date;

    switch (selectedRange) {
      case HistoryRange.today:
        return date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;

      case HistoryRange.week:
        final startOfWeek =
            now.subtract(Duration(days: now.weekday - 1));
        return date.isAfter(
          startOfWeek.subtract(const Duration(days: 1)),
        );

      case HistoryRange.month:
        return date.year == now.year &&
            date.month == now.month;

      case HistoryRange.all:
        return true;
    }
  }

  // ================= SMART SEARCH (PRIORITY BASED) =================
  bool _matchSearch(TransactionData tx) {
    if (searchQuery.trim().isEmpty) return true;

    final q = searchQuery.toLowerCase();

    final source = tx.source.toLowerCase();
    final category = tx.category.toLowerCase();
    final date = formatDate(tx.date).toLowerCase();
    final amount = tx.amount.toString();
    final type = transactionTypeLabel(tx.type).toLowerCase();
    final note = (tx.note ?? '').toLowerCase();

    if (source.contains(q)) return true;
    if (category.contains(q)) return true;
    if (date.contains(q)) return true;
    if (amount.contains(q)) return true;

    if (q.length > 2 && note.contains(q)) return true;

    if (type.contains(q)) return true;

    return false;
  }

  // ================= AUTO TYPE MATCH =================
  bool _matchType(TransactionData tx) {
    if (selectedType == 'All') return true;

    final group = transactionGroups[selectedType];

    if (group == null) return true;

    return group.contains(tx.type);
  }

  // ================= SORT =================
  List<TransactionData> _applySort(List<TransactionData> list) {
    switch (sortType) {
      case 'Oldest':
        list.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'Highest':
        list.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case 'Lowest':
        list.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      default:
        list.sort((a, b) => b.date.compareTo(a.date));
    }
    return list;
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: Column(
        children: [
          _rangeSelector(),
          const SizedBox(height: 8),
          _searchRow(),
          const SizedBox(height: 8),
          Expanded(child: _transactionList()),
        ],
      ),
    );
  }

  // ================= RANGE =================
Widget _rangeSelector() {
  return SizedBox(
    width: double.infinity,
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _chip("Today", HistoryRange.today),
          _chip("Week", HistoryRange.week),
          _chip("Month", HistoryRange.month),
          _chip("All", HistoryRange.all),
        ],
      ),
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
          setState(() => selectedRange = range);
        },
      ),
    );
  }

  // ================= SEARCH + FILTER =================
  Widget _searchRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (v) =>
                  setState(() => searchQuery = v),
              decoration: InputDecoration(
                hintText:
                    'Search source, category, date, amount...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                isDense: true,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // FILTER BUTTON (ENUM DRIVEN)
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_alt),
            onSelected: (value) {
              setState(() => selectedType = value);
            },
            itemBuilder: (_) => filterTypes
                .map(
                  (t) => PopupMenuItem(
                    value: t,
                    child: Text(t),
                  ),
                )
                .toList(),
          ),

          // SORT
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() => sortType = value);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'Newest',
                child: Text('Newest'),
              ),
              PopupMenuItem(
                value: 'Oldest',
                child: Text('Oldest'),
              ),
              PopupMenuItem(
                value: 'Highest',
                child: Text('Highest'),
              ),
              PopupMenuItem(
                value: 'Lowest',
                child: Text('Lowest'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= LIST =================
Widget _transactionList() {
  return ValueListenableBuilder(
    valueListenable:
        Hive.box<TransactionData>('transactions').listenable(),
    builder: (context, Box<TransactionData> box, _) {
      var transactions = box.values
          .where(_matchRange)
          .where(_matchSearch)
          .where(_matchType)
          .toList();

      transactions = _applySort(transactions);

      if (transactions.isEmpty) {
        return const Center(
          child: Text("No transactions found"),
        );
      }

      // ================= GROUP BY DATE =================
      final Map<String, List<TransactionData>> grouped = {};

      for (var tx in transactions) {
        final key = _getDateLabel(tx.date);

        grouped.putIfAbsent(key, () => []);
        grouped[key]!.add(tx);
      }

      final keys = grouped.keys.toList();

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: keys.length,
        itemBuilder: (context, index) {
          final dateKey = keys[index];
          final items = grouped[dateKey]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= DATE HEADER =================
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  dateKey,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ),

              // ================= ITEMS =================
              ...items.map(
                (tx) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TransactionPreview(tx: tx),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
}