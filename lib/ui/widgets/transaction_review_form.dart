import 'package:flutter/material.dart';

import '../../../models/parsed_transaction.dart';

class TransactionReviewForm
    extends StatefulWidget {

  final ParsedTransaction
      transaction;

  final Function(
    ParsedTransaction,
  ) onNext;

  const TransactionReviewForm({
    super.key,
    required this.transaction,
    required this.onNext,
  });

  @override
  State<TransactionReviewForm>
      createState() =>
          _TransactionReviewFormState();
}

class _TransactionReviewFormState
    extends State<
        TransactionReviewForm> {

  late TextEditingController
      sourceController;

  late TextEditingController
      amountController;

  late TextEditingController
      noteController;

  @override
  void initState() {

    super.initState();

    sourceController =
        TextEditingController(
      text:
          widget.transaction.source,
    );

    amountController =
        TextEditingController(
      text: widget
          .transaction.amount
          .toString(),
    );

    noteController =
        TextEditingController(
      text:
          widget.transaction.note ??
              '',
    );
  }

  @override
  void dispose() {

    sourceController.dispose();

    amountController.dispose();

    noteController.dispose();

    super.dispose();
  }

  void _submit() {

    final updated =
        widget.transaction.copyWith(

      source:
          sourceController.text.trim(),

      amount:
          double.tryParse(
            amountController.text,
          ) ??
          0,

      note:
          noteController.text.trim(),
    );

    widget.onNext(updated);
  }

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(

      padding:
          const EdgeInsets.all(16),

      child: Column(

        children: [

          TextField(

            controller:
                sourceController,

            decoration:
                const InputDecoration(

              labelText: 'Source',

              border:
                  OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          TextField(

            controller:
                amountController,

            keyboardType:
                TextInputType.number,

            decoration:
                const InputDecoration(

              labelText: 'Amount',

              border:
                  OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          TextField(

            controller:
                noteController,

            maxLines: 4,

            decoration:
                const InputDecoration(

              labelText: 'Note',

              border:
                  OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(

            width: double.infinity,

            child: ElevatedButton(

              onPressed: _submit,

              child: const Text(
                'Next',
              ),
            ),
          ),
        ],
      ),
    );
  }
}