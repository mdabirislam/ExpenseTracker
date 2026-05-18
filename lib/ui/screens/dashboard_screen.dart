import 'package:flutter/material.dart';
import 'paste_transactions_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
      ),

      body: const Center(
        child: Text("Your dashboard content here"),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const PasteTransactionsScreen(),
            ),
          );
        },
        child: const Icon(Icons.auto_fix_high),
      ),
    );
  }
}