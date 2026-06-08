// transaction_preview_card.dart

import 'package:flutter/material.dart';

import '../../models/transaction_draft.dart';

class TransactionPreviewCard
    extends StatelessWidget {

  final TransactionDraft draft;

  const TransactionPreviewCard({
    super.key,
    required this.draft,
  });

  @override
  Widget build(BuildContext context) {

    return Card(

      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),

      child: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Text(
              'Transaction ${draft.index}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Date: ${draft.date}',
            ),

            Text(
              'Type: ${draft.type?.name}',
            ),

            Text(
              'Source: ${draft.source}',
            ),

            Text(
              'Amount: ${draft.amount}',
            ),

            Text(
              'Category: ${draft.category}',
            ),

            if (draft.note != null)

              Padding(

                padding:
                    const EdgeInsets.only(
                  top: 12,
                ),

                child: Text(
                  'Note:\n${draft.note}',
                ),
              ),
          ],
        ),
      ),
    );
  }
}