import 'package:flutter/material.dart';

class AppBarWidget extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onLanguageTap;
  final VoidCallback? onThemeTap;

  const AppBarWidget({
    super.key,
    required this.title,
    this.onLanguageTap,
    this.onThemeTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.language),
          onPressed: onLanguageTap,
        ),
        IconButton(
          icon: const Icon(Icons.dark_mode_outlined),
          onPressed: onThemeTap,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
