import 'chat_input_validator.dart';
import 'transaction_block_splitter.dart';
import 'transaction_parser.dart';
import 'parser_result.dart';
import '../../models/parsed_transaction.dart';
import 'validation_error.dart';

class TransactionChatService {

  static ParserResult process(String input) {

    final validationErrors =
        ChatInputValidator.validate(input);

    if (validationErrors.isNotEmpty) {
      return ParserResult.error(validationErrors);
    }

    final blocks =
        TransactionBlockSplitter.split(input);

    List<ParsedTransaction> transactions = [];
    List<ValidationError> errors = [];

    for (int i = 0; i < blocks.length; i++) {

      final result =
          TransactionParser.parseBlock(blocks[i], i);

      transactions.addAll(result.transactions);
      errors.addAll(result.errors);
    }

    // SAFETY FILTER
    transactions.removeWhere((t) =>
        t.source.trim().isEmpty || t.amount <= 0);

    return ParserResult(
      transactions: transactions,
      errors: errors,
    );
  }
}