import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ───── Info Boards ─────
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                _DashboardBoard(
                  title: 'Total Expense',
                  value: '৳ 0',
                  onTap: () {
                    // future: navigate to expense details
                  },
                ),
                _DashboardBoard(
                  title: 'Total Debt',
                  value: '৳ 0',
                  onTap: () {
                    // future: navigate to debt details
                  },
                ),
                _DashboardBoard(
                  title: 'Savings',
                  value: '৳ 0',
                  onTap: () {
                    // future: navigate to savings details
                  },
                ),
                _DashboardBoard(
                  title: 'Income Sources',
                  value: '৳ 0',
                  onTap: () {
                    // future: navigate to income sources
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ───── Charts Placeholder ─────
            Container(
              height: 200,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Charts & Analysis will appear here',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────── Reusable Dashboard Board ───────────

class _DashboardBoard extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback onTap;

  const _DashboardBoard({
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
