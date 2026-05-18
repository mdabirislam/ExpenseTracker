import 'transaction_draft.dart';
import 'validation_error.dart';

class ParserResult {
  final List<TransactionDraft> drafts;

  final List<ValidationError> errors;

  ParserResult({
    required this.drafts,
    required this.errors,
  });

  bool get hasErrors => errors.isNotEmpty;
}
