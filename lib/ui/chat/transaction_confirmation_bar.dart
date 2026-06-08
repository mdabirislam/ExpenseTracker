// transaction_confirmation_bar.dart

import 'package:flutter/material.dart';

import '../../models/transaction_draft.dart';

class TransactionConfirmationBar
    extends StatelessWidget {

  final List<TransactionDraft> drafts;

  const TransactionConfirmationBar({
    super.key,
    required this.drafts,
  });

  void _saveAll(BuildContext context) {

    ScaffoldMessenger.of(context)
        .showSnackBar(

      SnackBar(
        content: Text(
          '${drafts.length} transactions saved',
        ),
      ),
    );
  }

  void _review(BuildContext context) {

    ScaffoldMessenger.of(context)
        .showSnackBar(

      const SnackBar(
        content: Text(
          'Review screen not connected yet',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Container(

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(

        color: Theme.of(context)
            .scaffoldBackgroundColor,

        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            color: Colors.black.withOpacity(0.08),
          ),
        ],
      ),

      child: Row(

        children: [

          Expanded(

            child: ElevatedButton(

              onPressed: () =>
                  _saveAll(context),

              child: const Text(
                'Save All',
              ),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(

            child: OutlinedButton(

              onPressed: () =>
                  _review(context),

              child: const Text(
                'Review Transactions',
              ),
            ),
          ),
        ],
      ),
    );
  }
}