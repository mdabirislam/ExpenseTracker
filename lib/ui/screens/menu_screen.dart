import 'package:flutter/material.dart';
import 'after_click_screen/SetMonthScreen.dart';
import '../../data/local/app_state.dart';
import '../../utils/date_utils.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              // Ensure Hive box is ready
              // await AppState.initMonths();
//init on app start on main, not here
              final existingRange = AppState.getCurrentMonthRange();

              if (existingRange != null) {
                // Popup if month range exists
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Month Range Exists"),
                    content: Text(
                      "Month: ${existingRange.monthName}\n"
                      "Start: ${formatDate(existingRange.start)}\n"
                      "End: ${formatDate(existingRange.end)}\n\n"
                      "Do you want to edit it?"
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
                                  fixedDays: existingRange.end.difference(existingRange.start).inDays + 1,
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
                // No data → open directly
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SetMonthScreen()),
                );
              }
            },
          ),
          _buildMenuTile(
            icon: Icons.save,
            title: 'Save / Delete Month Data',
            onTap: () {},
          ),
          _buildMenuTile(
            icon: Icons.dark_mode,
            title: 'App Theme / Dark Mode',
            onTap: () {},
          ),
          _buildMenuTile(
            icon: Icons.language,
            title: 'Language Switch',
            onTap: () {},
          ),
          _buildMenuTile(
            icon: Icons.exit_to_app,
            title: 'Exit',
            onTap: () {},
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