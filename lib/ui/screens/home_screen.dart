import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../widgets/app_bar_widget.dart';
import '../widgets/balance_summary.dart';
import '../widgets/info_board.dart';
import '../widgets/transaction_preview.dart';
import '../widgets/fab_menu.dart';
import '../widgets/charts/monthly_bar_chart.dart';
import '../../models/transaction_model.dart';
import '../placeholders/ui_vars.dart';
import './after_click_screen/add_transaction_screen.dart';
import '../../data/local/app_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // ───── FAB actions ─────
  void onAddTransaction(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
    );
  }

  void _onStartNewMonth() {
    debugPrint('Start New Month tapped');
    // future: archive month + savings logic
  }

  @override
  Widget build(BuildContext context) {
    final _txBox = Hive.box<TransactionData>('transactions'); // use _txBox

    return ValueListenableBuilder(
      valueListenable: _txBox.listenable(),
      builder: (context, Box<TransactionData> box, _) {
        // 🔹 Recalculate totals whenever transactions change
        AppState.recalculateFromBox();

        final transactions = box.values.toList().reversed.toList();

        return Scaffold(
          appBar: AppBarWidget(
            title: 'Home',
            onLanguageTap: () {},
            onThemeTap: () {},
          ),
          floatingActionButton: FabMenu(
            onAddTransaction: () => onAddTransaction(context),
            onStartNewMonth: _onStartNewMonth,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBalanceSummary(),
                const SizedBox(height: 16),
                _infoBoards(),
                const SizedBox(height: 20),
                _shortHistory(transactions),
                const SizedBox(height: 20),
                const MonthlyBarChart(),
              ],
            ),
          ),
        );
      },
    );
  }

  // ───────── Balance Summary ─────────
  Widget _buildBalanceSummary() {
    return BalanceSummary(
      balance: '৳ ${AppState.balance.toStringAsFixed(2)}',
      statusText: AppState.balance >= 0 ? 'You are under budget' : 'Over budget',
      statusColor: AppState.balance >= 0 ? Colors.green : Colors.red,
    );
  }

  // ───────── Info Boards ─────────
  Widget _infoBoards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        InfoBoard(title: boardExpenseTitle, value: '৳ ${AppState.totalExpense.toStringAsFixed(2)}'),
        InfoBoard(title: boardDebtTitle, value: '৳ ${AppState.totalDebt.toStringAsFixed(2)}'),
        // debtToPay removed as per new design
        InfoBoard(title: boardSavingsTitle, value: '৳ ${AppState.savings.toStringAsFixed(2)}'),
      ],
    );
  }

  // ───────── Short History ─────────
  Widget _shortHistory(List<TransactionData> transactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            TextButton(onPressed: () {}, child: const Text('See all')),
          ],
        ),
        const SizedBox(height: 8),
        ...transactions.take(3).map((tx) => TransactionPreview(tx: tx)).toList(),
      ],
    );
  }
}