import 'package:flutter/material.dart';

class UnknownCategoryChip
    extends StatelessWidget {

  final String category;

  final VoidCallback onCreate;

  final VoidCallback onUseAsNote;

  const UnknownCategoryChip({
    super.key,
    required this.category,
    required this.onCreate,
    required this.onUseAsNote,
  });

  @override
  Widget build(BuildContext context) {

    return Wrap(

      spacing: 8,

      children: [

        Chip(
          label: Text(
            'Unknown: $category',
          ),
        ),

        ActionChip(
          label: const Text(
            'Create Category',
          ),
          onPressed: onCreate,
        ),

        ActionChip(
          label: const Text(
            'Use as Note',
          ),
          onPressed: onUseAsNote,
        ),
      ],
    );
  }
}