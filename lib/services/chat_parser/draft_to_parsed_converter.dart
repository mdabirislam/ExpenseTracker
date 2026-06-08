import '../../models/parsed_transaction.dart';
import '../../models/transaction_draft.dart';

class DraftToParsedConverter {

  static ParsedTransaction convert(
    TransactionDraft draft,
  ) {

    return ParsedTransaction(

      source: draft.source!,

      amount: draft.amount!,

      note: draft.note,

      category: draft.category ?? 'Other',

      type: draft.type!,

      date: draft.date!,

      categoryConfidence: true,

      typeConfidence: true,

      typeGuessed: false,

      categoryGuessed: false,
    );
  }
}