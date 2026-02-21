
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/transaction_model.dart';
import '../widgets/transaction_preview.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: Column(
        children: [
          _searchFilterSection(),
          const SizedBox(height: 12),
          Expanded(child: _transactionList()),
        ],
      ),
    );
  }

  Widget _searchFilterSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by date, amount, type...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(icon: const Icon(Icons.filter_alt), onPressed: () {}),
        ],
      ),
    );
  }

  Widget _transactionList() {
    return ValueListenableBuilder(
      valueListenable: Hive.box<TransactionData>('transactions').listenable(),
      builder: (context, Box<TransactionData> box, _) {
        final transactions = box.values.toList().reversed.toList();
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: transactions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) => TransactionPreview(tx: transactions[index]),
        );
      },
    );
  }
}
