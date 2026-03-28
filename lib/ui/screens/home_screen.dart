import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../widgets/app_bar_widget.dart';
import '../widgets/balance_summary.dart';
import '../widgets/info_board.dart';
import '../widgets/transaction_preview.dart';
// import '../widgets/fab_menu.dart';
import '../widgets/charts/monthly_bar_chart.dart';
import '../../models/transaction_model.dart';
import '../placeholders/ui_vars.dart';
import './after_click_screen/add_transaction_screen.dart';
import '../../data/local/app_state.dart';
import './history_screen.dart';
import '../widgets/charts/category_pie_chart.dart';
// import './../../utils/helpers.dart';
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

  // void _onStartNewMonth() {
  //   debugPrint('Start New Month tapped');
  //   // future: archive month + savings logic
  // }

void _navigate(BuildContext context, Widget screen) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => screen),
  );
}


  @override
  Widget build(BuildContext context) {
    final _txBox = Hive.box<TransactionData>('transactions'); // use _txBox

    return ValueListenableBuilder(
      valueListenable: _txBox.listenable(),
      builder: (context, Box<TransactionData> box, _) {
        // 🔹 Recalculate totals whenever transactions change
        // AppState.recalculateFromBox();

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

  // ───────── Balance Summary ─────────
Widget _buildBalanceSummary() {
  // final summary = AppState.getCurrentMonthSummary();

  return BalanceSummary(
    // balance: '৳ ${summary.balance.toStringAsFixed(2)}',
    balance: '৳ ${AppState.balance.toStringAsFixed(2)}',
    statusText: AppState.balance >= 0
    // statusText: summary.balance >= 0
        ? 'You are under budget'
        : 'Over budget',
    statusColor:
        AppState.balance >= 0 ? Colors.green : Colors.red,
        // statusColor: summary.balance >= 0 ? Colors.green : Colors.red,
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
              // tooltip: 'See Full History',
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
