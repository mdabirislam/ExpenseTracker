import 'package:uuid/uuid.dart';

import '../../data/local/app_state.dart';

import '../../models/transaction_model.dart';

import '../../models/parsed_transaction.dart';

import '../../utils/helpers.dart';

class SaveAllTransactionsService {

  static Future<void> save(
    List<ParsedTransaction> transactions,
  ) async {

    for (final tx in transactions) {

      final data = TransactionData(

        id: const Uuid().v4(),

        type: tx.type,

        amount: tx.amount,

        source: tx.source,

        note: tx.note,

        category: tx.category,

        date: tx.date,

        monthKey:
            generateMonthKey(tx.date),
      );

      await AppState.addTransaction(data);
    }
  }
}