import 'package:flutter/material.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu / Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMenuTile(
            icon: Icons.undo,
            title: 'Undo Last Action',
            onTap: () {},
          ),
          _buildMenuTile(
            icon: Icons.restart_alt,
            title: 'Reset / Start New Year',
            onTap: () {},
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
