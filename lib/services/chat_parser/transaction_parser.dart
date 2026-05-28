import '../../models/parsed_transaction.dart';
import '../../models/transaction_type.dart';

// import 'field_validator.dart';
import 'validation_error.dart';

class TransactionParser {

  static ParseResult parseBlock(
    String block,
    int index,
  ) {

    List<ValidationError> errors = [];
    List<ParsedTransaction> transactions = [];

    DateTime? currentDate;

    ParsedTransaction? lastTransaction;

    bool multilineMode = false;

    String multilineBuffer = '';

    final lines = block.split('\n');

    for (final rawLine in lines) {

      final line = rawLine.trim();

      if (line.isEmpty) continue;

      // ================= MULTILINE NOTE =================

      if (line == '"""') {

        multilineMode = !multilineMode;

        // NOTE END
        if (!multilineMode) {

          if (lastTransaction != null) {

            final updated =
                lastTransaction.copyWith(
              note: multilineBuffer.trim(),
            );

            transactions[
                transactions.length - 1] = updated;

            lastTransaction = updated;
          }

          multilineBuffer = '';
        }

        continue;
      }

      // INSIDE MULTILINE
      if (multilineMode) {

        multilineBuffer += '$line\n';

        continue;
      }

      // ================= DATE =================

      final dateMatch = RegExp(
        r'^(\d{1,2})[-/.](\d{1,2})[-/.](\d{2,4})$',
      ).firstMatch(line);

      if (dateMatch != null) {

        int d =
            int.parse(dateMatch.group(1)!);

        int m =
            int.parse(dateMatch.group(2)!);

        int y =
            int.parse(dateMatch.group(3)!);

        if (y < 100) y += 2000;

        currentDate = DateTime(y, m, d);

        continue;
      }

      // ================= TRANSACTION =================

      if (line.contains('-')) {

        final parts = line.split('-');

        String source = parts[0].trim();

        TransactionType type =
            TransactionType.expense;

        String? unknownType;

        final typeMatch =
            RegExp(r'^(.*?)\((.*?)\)$')
                .firstMatch(source);

        if (typeMatch != null) {

          source =
              typeMatch.group(1)!.trim();

          final rawType =
              typeMatch.group(2)!
                  .trim()
                  .toLowerCase();

          switch (rawType) {

            case 'income':
              type = TransactionType.income;
              break;

            case 'expense':
              type = TransactionType.expense;
              break;

            case 'borrow':
              type = TransactionType.debtBorrow;
              break;

            case 'repay':
              type = TransactionType.debtRepay;
              break;

            case 'lend':
              type = TransactionType.lendGive;
              break;

            case 'receive':
              type = TransactionType.lendReceive;
              break;

            default:
              type = TransactionType.expense;
              unknownType = rawType;
          }
        }

        final right =
            parts.sublist(1).join('-');

        final amountMatch =
            RegExp(r'(\d[\d,]*)')
                .firstMatch(right);

        if (amountMatch == null) {

          errors.add(
            ValidationError(
              index: index,
              message:
                  "Missing amount in: $line",
            ),
          );

          continue;
        }

        final amount = double.parse(
          amountMatch.group(1)!
              .replaceAll(',', ''),
        );

        final categoryMatch =
            RegExp(r'\((.*?)\)')
                .firstMatch(right);

        final category =
            categoryMatch?.group(1) ??
                "Other";

        final tx = ParsedTransaction(
          source: source,
          amount: amount,
          category: category,
          type: type,
          date:
              currentDate ??
                  DateTime.now(),
          note: null,

          categoryConfidence: true,
          typeConfidence: true,
          typeGuessed: false,
          categoryGuessed: false,

          unknownType: unknownType,
        );

        transactions.add(tx);

        lastTransaction = tx;
      }
    }

    return ParseResult(
      transactions: transactions,
      errors: errors,
    );
  }
}

class ParseResult {

  final List<ParsedTransaction>
      transactions;

  final List<ValidationError>
      errors;

  ParseResult({
    required this.transactions,
    required this.errors,
  });
}