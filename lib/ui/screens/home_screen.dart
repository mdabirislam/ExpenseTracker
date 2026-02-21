import 'package:flutter/material.dart';

import '../widgets/app_bar_widget.dart';
import '../widgets/balance_summary.dart';
import '../widgets/info_board.dart';
import '../widgets/transaction_preview.dart';
import '../widgets/fab_menu.dart';
import '../widgets/charts/monthly_bar_chart.dart';
import '../../data/local/app_state.dart';
import '../placeholders/ui_vars.dart';
import './after_click_screen/add_transaction_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // ───── FAB actions ─────
  void onAddTransaction(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const AddTransactionScreen(),
      ),
    );
  }

  void _onStartNewMonth() {
    debugPrint('Start New Month tapped');
    // future: archive month + savings logic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ───── AppBar ─────
      appBar: AppBarWidget(
        title: 'Home',
        onLanguageTap: () {},
        onThemeTap: () {},
      ),

      // ───── FAB ─────
      floatingActionButton: FabMenu(
        onAddTransaction: () => onAddTransaction(context),
        onStartNewMonth: _onStartNewMonth,
      ),

      // ───── Body ─────
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceSummary(),
            const SizedBox(height: 16),
            _infoBoards(),
            const SizedBox(height: 20),
            _shortHistory(),
            const SizedBox(height: 20),
            const MonthlyBarChart(),
          ],
        ),
      ),
    );
  }

  // ───────── Balance Summary ─────────
  Widget _buildBalanceSummary() {
    return BalanceSummary(
      balance:  '৳ ${AppState.balance.toStringAsFixed(2)}',
       statusText: AppState.balance >= 0
          ? 'You are under budget'
          : 'Over budget',
      statusColor:
          AppState.balance >= 0 ? Colors.green : Colors.red,
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
        InfoBoard(
          title: boardExpenseTitle,
          value: '৳ ${AppState.totalExpense}',
        ),
        InfoBoard(title: boardDebtTitle, value: '৳ ${AppState.totalDebt}'),
        InfoBoard(title: boardDebtToPayTitle, value: '৳ ${AppState.debtToPay}'),
        InfoBoard(title: boardSavingsTitle, value: '৳ ${AppState.savings}'),
      ],
    );
  }

  // ───────── Short History ─────────
  Widget _shortHistory() {
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
        ...AppState.transactions
            .take(3)
            .map((tx) => TransactionPreview(tx: tx)),
      ],
    );
  }
}
