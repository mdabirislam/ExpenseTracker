import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../widgets/app_bar_widget.dart';
import '../widgets/balance_summary.dart';
import '../widgets/info_board.dart';
import '../widgets/transaction_preview.dart';
import '../widgets/charts/monthly_bar_chart.dart';
import '../../models/transaction_model.dart';
import '../placeholders/ui_vars.dart';
import './after_click_screen/add_transaction_screen.dart';
import '../../data/local/app_state.dart';
import './history_screen.dart';
import '../widgets/charts/category_pie_chart.dart';
import 'after_click_screen/IncomeDetailScreen.dart';
import 'after_click_screen/DebtDetailScreen.dart';
import 'after_click_screen/SavingsDetailScreen.dart';
import 'after_click_screen/ExpenseDetailScreen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // ───── FAB actions ─────
  void onAddTransaction(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
    );
  }

  void onSeeAll(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HistoryScreen()),
    );
  }

  void _navigate(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final _txBox = Hive.box<TransactionData>('transactions');

    return ValueListenableBuilder(
      valueListenable: _txBox.listenable(),
      builder: (context, Box<TransactionData> box, _) {
        final transactions = box.values.toList().reversed.toList();

        return Scaffold(
          appBar: AppBarWidget(
            title: 'Home',
            onLanguageTap: () {},
            onThemeTap: () {},
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => onAddTransaction(context),
            tooltip: 'Add Transaction',
            child: const Icon(Icons.add),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBalanceSummary(),
                const SizedBox(height: 16),
                _infoBoards(context),
                const SizedBox(height: 20),
                _shortHistory(context, transactions),
                const SizedBox(height: 20),
                const MonthlyBarChart(),
                const SizedBox(height: 20),
                const CategoryPieChart(),
              ],
            ),
          ),
        );
      },
    );
  }

  // / Mini text widget for extra info in balance card
  Widget _miniText(
    String text, {
    Color? color,
    bool isBold = false,
  }) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        color: color ?? Colors.black54,
        fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  // Balance summary card
  Widget _buildBalanceSummary() {
  final summary = AppState.getCurrentMonthSummary();
  final range = AppState.getCurrentMonthRange();

  final currentIncome = summary.income;
  final previousBalance = AppState.balance - summary.balance;
  final lent = summary.lend;

  List<Widget> headerTexts = [];

  if (range == null) {
    headerTexts.add(_miniText(
      '⚠ Please set current month',
      color: Colors.redAccent,
      isBold: true,
    ));
    headerTexts.add(_miniText(
      'Not set',
      color: Colors.red[300],
    ));
  } else {
    String monthName = DateFormat.MMMM().format(range.monthRef);
    String year = DateFormat.y().format(range.monthRef);
    headerTexts.add(
      Align(
        alignment: Alignment.centerRight,
        child: _miniText(
          '$monthName $year',
          color: Colors.green[700],
          isBold: true,
        ),
      ),
    );

    String start = DateFormat('d MMM').format(range.start);
    String end = DateFormat('d MMM').format(range.end);
    headerTexts.add(
      Align(
        alignment: Alignment.centerRight,
        child: _miniText(
          '$start – $end',
          color: Colors.orange[800],
        ),
      ),
    );
  }

  if (headerTexts.isNotEmpty) headerTexts.add(const SizedBox(height: 1));

  Widget _financeRow(String label, double value, Color? color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: _miniText(
              label,
              color: color,
              isBold: false,
            ),
          ),
          _miniText('৳', color: Colors.black54, isBold: true),
          const SizedBox(width: 1),
          _miniText(
            value.toStringAsFixed(0),
            color: color,
            isBold: false,
          ),
        ],
      ),
    );
  }

  List<Widget> financialRows = [];
  if (currentIncome > 0) financialRows.add(_financeRow('Income', currentIncome, Colors.green[600]));
  if (previousBalance > 0) financialRows.add(_financeRow('Previous Balance', previousBalance, Colors.teal[600]));
  if (lent > 0) financialRows.add(_financeRow('Lent', lent, Colors.red[400]));

  return Stack(
    clipBehavior: Clip.none,
    children: [
      BalanceSummary(
        balance: '৳ ${AppState.balance.toStringAsFixed(2)}',
        statusText: AppState.balance >= 0 ? 'You are under budget' : 'Over budget',
        statusColor: AppState.balance >= 0 ? Colors.green : Colors.red,
      ),
      Positioned(
        top: 8,
        right: 10, // সামান্য right padding, একদম লাগেনি না
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 160), // বেশি লম্বা হলে ভেঙে যাবে
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ...headerTexts,
                ...financialRows,
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
  //___________ Info Boards ___________
  Widget _infoBoards(BuildContext context) {
    final summary = AppState.getCurrentMonthSummary();

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        InkWell(
          onTap: () => _navigate(context, IncomeDetailScreen()),
          child: InfoBoard(
            title: boardIncomeTitle,
            value: '৳ ${summary.income.toStringAsFixed(2)}',
          ),
        ),
        InkWell(
          onTap: () => _navigate(context, ExpenseDetailScreen()),
          child: InfoBoard(
            title: boardExpenseTitle,
            value: '৳ ${summary.expense.toStringAsFixed(2)}',
          ),
        ),
        InkWell(
          onTap: () => _navigate(context, DebtDetailScreen()),
          child: InfoBoard(
            title: boardDebtTitle,
            value: '৳ ${summary.debt.toStringAsFixed(2)}',
          ),
        ),
        InkWell(
          onTap: () => _navigate(context, SavingsDetailScreen()),
          child: InfoBoard(
            title: boardSavingsTitle,
            value: '৳ ${summary.savings.toStringAsFixed(2)}',
          ),
        ),
      ],
    );
  }

  // ───────── Short History ─────────
  Widget _shortHistory(
    BuildContext context,
    List<TransactionData> transactions,
  ) {
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
            TextButton(
              onPressed: () => onSeeAll(context),
              child: const Text('See all'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...transactions
            .take(3)
            .map((tx) => TransactionPreview(tx: tx))
            .toList(),
      ],
    );
  }
}