import 'package:flutter/material.dart';
import '../../data/local/app_state.dart';
// import '../../models/month_range_model.dart';
import 'after_click_screen/SetMonthScreen.dart';
import 'package:intl/intl.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {

  String formatMonth(DateTime d) {
    return DateFormat('MMM yyyy').format(d);
  }

  String formatDate(DateTime d) {
    return DateFormat('dd MMM yyyy').format(d);
  }

  @override
  Widget build(BuildContext context) {
    final current = AppState.getCurrentMonthRange();
    final allMonths = AppState.allMonths;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu / Settings (Test Mode)'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          /// 🔥 Set Month Button
          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text("Set Month"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SetMonthScreen(),
                  ),
                );

                setState(() {}); // refresh after return
              },
            ),
          ),

          const SizedBox(height: 10),

          /// 🔥 Current Month Info
          Card(
            child: ListTile(
              leading: const Icon(Icons.info),
              title: const Text("Current Month"),
              subtitle: current == null
                  ? const Text("No month set")
                  : Text(
                      "${formatMonth(current.monthRef)}\n"
                      "Start: ${formatDate(current.start)}\n"
                      "End: ${formatDate(current.end)}",
                    ),
            ),
          ),

          const SizedBox(height: 20),

          /// 🔥 All Saved Months (Debug View)
          const Text(
            "Saved Months (Debug)",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          if (allMonths.isEmpty)
            const Text("No data saved yet"),

          ...allMonths.map((m) {
            return Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(formatMonth(m.monthRef)),
                subtitle: Text(
                  "Start: ${formatDate(m.start)}\n"
                  "End: ${formatDate(m.end)}",
                ),
              ),
            );
          }),

          const SizedBox(height: 30),

          /// ⚠️ Safe Placeholder Buttons (No Logic)
          _buildDisabledTile(Icons.undo, "Undo (Coming soon)"),
          _buildDisabledTile(Icons.save, "Save/Delete (Coming soon)"),
          _buildDisabledTile(Icons.dark_mode, "Theme (Coming soon)"),
          _buildDisabledTile(Icons.language, "Language (Coming soon)"),
        ],
      ),
    );
  }

  Widget _buildDisabledTile(IconData icon, String title) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.lock_outline),
      ),
    );
  }
}