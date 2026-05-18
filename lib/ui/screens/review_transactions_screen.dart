import 'package:flutter/material.dart';

import '../../models/parsed_transaction.dart';

import '../widgets/transaction_review_form.dart';

class ReviewTransactionsScreen
    extends StatefulWidget {

  final List<ParsedTransaction>
      transactions;

  const ReviewTransactionsScreen({
    super.key,
    required this.transactions,
  });

  @override
  State<ReviewTransactionsScreen>
      createState() =>
          _ReviewTransactionsScreenState();
}

class _ReviewTransactionsScreenState
    extends State<
        ReviewTransactionsScreen> {

  int currentIndex = 0;

  late List<ParsedTransaction>
      transactions;

  @override
  void initState() {

    super.initState();

    transactions =
        List.from(widget.transactions);
  }

  Future<void> _next(
    ParsedTransaction tx,
  ) async {

    if (currentIndex <
        transactions.length - 1) {

      setState(() {

        transactions[currentIndex] =
            tx;

        currentIndex++;
      });
    }

    else {

      if (!mounted) return;

      Navigator.pop(
        context,
        transactions,
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    final tx =
        transactions[currentIndex];

    return Scaffold(

      appBar: AppBar(

        title: Text(
          'Review ${currentIndex + 1}/${transactions.length}',
        ),
      ),

      body: TransactionReviewForm(

        key: ValueKey(currentIndex),

        transaction: tx,

        onNext: _next,
      ),
    );
  }
}