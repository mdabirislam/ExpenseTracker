import '../../models/parsed_transaction.dart';
import 'validation_error.dart';

class ParserResult {

  final List<ParsedTransaction> transactions;
  final List<ValidationError> errors;

  ParserResult({
    required this.transactions,
    required this.errors,
  });

  bool get hasErrors => errors.isNotEmpty;
  bool get hasTransactions => transactions.isNotEmpty;

  factory ParserResult.error(List<String> msgs) {
    return ParserResult(
      transactions: [],
      errors: msgs
          .map((e) => ValidationError(index: -1, message: e))
          .toList(),
    );
  }
}