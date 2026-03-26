import 'package:flutter/material.dart';
import 'after_click_screen/SetMonthScreen.dart';
import '../../data/local/app_state.dart';
import '../../utils/date_utils.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {

    /// ✅ check on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkMonthStatus(context);
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Menu / Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMenuTile(
            icon: Icons.undo,
            title: 'Undo Last Action',
            onTap: () => debugPrint('Undo tapped'),
          ),
          _buildMenuTile(
            icon: Icons.calendar_month,
            title: 'Set Month',
            onTap: () async {
              final existingRange = AppState.getCurrentMonthRange();

              if (existingRange != null) {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Month Range Exists"),
                    content: Text(
                      "Month: ${existingRange.monthName}\n"
                      "Start: ${formatDate(existingRange.start)}\n"
                      "End: ${formatDate(existingRange.end)}",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SetMonthScreen(
                                initialSettings: MonthSettings(
                                  startDate: existingRange.start,
                                  startMode: 'custom',
                                  endMode: 'fixed',
                                  fixedDays: existingRange.end
                                          .difference(existingRange.start)
                                          .inDays +
                                      1,
                                ),
                              ),
                            ),
                          );
                        },
                        child: const Text("Edit"),
                      ),
                    ],
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SetMonthScreen()),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  /// ✅ check logic
  void _checkMonthStatus(BuildContext context) {
    final days = AppState.getRemainingDays();

    if (days != null && days <= 5) {
      _showMonthAlert(context, days);
    }
  }

  /// ✅ popup
  void _showMonthAlert(BuildContext context, int days) {
    final range = AppState.getCurrentMonthRange();
    if (range == null) return;

    Color statusColor;
    if (days <= 3) {
      statusColor = Colors.red;
    } else if (days <= 5) {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.green;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Month Info"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Month: ${range.monthName}"),
            Text("Start: ${formatDate(range.start)}"),
            Text("End: ${formatDate(range.end)}"),

            const SizedBox(height: 10),

            Row(
              children: [
                const Text("Remaining: "),
                Text(
                  "$days days",
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              days <= 3
                  ? "তুমি কি বর্তমান মাস পরিবর্তন করতে চাও নাকি next month set করতে চাও?"
                  : "তুমি কি বর্তমান মাস পরিবর্তন করতে চাও?",
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),

          /// edit current
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SetMonthScreen(
                    initialSettings: MonthSettings(
                      startDate: range.start,
                      startMode: 'custom',
                      endMode: 'fixed',
                      fixedDays:
                          range.end.difference(range.start).inDays + 1,
                    ),
                  ),
                ),
              );
            },
            child: const Text("Edit Current"),
          ),

          /// next month
          if (days <= 3)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SetMonthScreen(),
                  ),
                );
              },
              child: const Text("Set Next Month"),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}