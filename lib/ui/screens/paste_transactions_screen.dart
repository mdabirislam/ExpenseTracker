import 'package:flutter/material.dart';

class PasteTransactionsScreen
    extends StatelessWidget {

  const PasteTransactionsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'Paste Transactions',
        ),
      ),

      body: const Center(
        child: Text(
          'Old Paste Parser',
        ),
      ),
    );
  }
}