import '../../models/parser_result.dart';
import 'transaction_lexer.dart';
import 'transaction_parser.dart';
import 'validation_engine.dart';
import 'syntax_validator.dart';

class TransactionChatService {

  static ParserResult process(String input) {

    if (SyntaxValidator.isRandomMessage(input)) {

      return ParserResult(
        drafts: [],
        errors: [],
      );
    }

    final lines =
        TransactionLexer.tokenize(input);

    final parsed =
        TransactionParser.parse(lines);

    final validationErrors =
        ValidationEngine.validate(
      parsed.drafts,
    );

    return ParserResult(
      drafts: parsed.drafts,
      errors: [
        ...parsed.errors,
        ...validationErrors,
      ],
    );
  }
}
