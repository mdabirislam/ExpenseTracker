import 'package:flutter/material.dart';

import '../../models/parsed_transaction.dart';

import '../../ui/screens/review_transactions_screen.dart';

class ReviewTransactionsConnector {

  static Future<void> open(

    BuildContext context,

    List<ParsedTransaction> transactions,
  ) async {

    await Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) =>
            ReviewTransactionsScreen(
          transactions: transactions,
        ),
      ),
    );
  }
}