import '../../models/parsed_transaction.dart';
import '../../models/transaction_type.dart';
import 'field_validator.dart';
import 'validation_error.dart';

class TransactionParser {

  static ParseResult parseBlock(String block, int index) {

    List<ValidationError> errors = [];
    List<ParsedTransaction> transactions = [];

    DateTime? currentDate;

    final lines = block.split('\n');

    for (final line in lines) {

      // DATE
      final dateMatch = RegExp(
        r'^(\d{1,2})[-/.](\d{1,2})[-/.](\d{2,4})',
      ).firstMatch(line);

      if (dateMatch != null) {
        int d = int.parse(dateMatch.group(1)!);
        int m = int.parse(dateMatch.group(2)!);
        int y = int.parse(dateMatch.group(3)!);

        if (y < 100) y += 2000;

        currentDate = DateTime(y, m, d);
        continue;
      }

      // TRANSACTION
      if (line.contains('-')) {

        final parts = line.split('-');

String source = parts[0].trim();

TransactionType type =
    TransactionType.expense;

String? unknownType;

final typeMatch =
    RegExp(r'^(.*?)\((.*?)\)$')
        .firstMatch(source);

const validTypes = {

  'income': TransactionType.income,

  'expense': TransactionType.expense,

  'borrow': TransactionType.debtBorrow,

  'repay': TransactionType.debtRepay,

  'lend': TransactionType.lendGive,

  'receive': TransactionType.lendReceive,
};

if (typeMatch != null) {

  source =
      typeMatch.group(1)!
          .trim();

  final rawType =
      typeMatch.group(2)!
          .trim()
          .toLowerCase();

  if (validTypes.containsKey(rawType)) {

    type =
        validTypes[rawType]!;

  } else {

    unknownType = rawType;

    type =
        TransactionType.expense;
  }
}
        final right = parts.sublist(1).join('-');

        final amountMatch =
            RegExp(r'(\d[\d,]*)').firstMatch(right);

        if (amountMatch == null) {
          errors.add(ValidationError(
            index: index,
            message: "Missing amount in: $line",
          ));
          continue;
        }

        final amount =
            double.parse(amountMatch.group(1)!.replaceAll(',', ''));

        final categoryMatch =
            RegExp(r'\((.*?)\)').firstMatch(right);

        final category =
            categoryMatch?.group(1) ?? "Other";

        transactions.add(ParsedTransaction(
          source: source,
          amount: amount,
          category: category,
          type: type,
          date: currentDate ?? DateTime.now(),
          note: null,
          categoryConfidence: true,
          typeConfidence: true,
          typeGuessed: false,
          categoryGuessed: false,
          unknownType: unknownType,
        ));
      }
    }

    return ParseResult(
      transactions: transactions,
      errors: errors,
    );
  }
}

class ParseResult {
  final List<ParsedTransaction> transactions;
  final List<ValidationError> errors;

  ParseResult({
    required this.transactions,
    required this.errors,
  });
}