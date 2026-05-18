import '../../models/transaction_type.dart';
import '../../models/transaction_draft.dart';
import '../../models/parser_result.dart';
import '../../models/validation_error.dart';

class TransactionParser {

  static final RegExp dateRegex =
      RegExp(r'^(\d{1,2})[-/](\d{1,2})[-/](\d{2,4})$');

  static final RegExp txRegex =
      RegExp(
    r'^(.*?)\s*(?:\((.*?)\))?\s*-\s*(\d+(?:\.\d+)?)\s*(?:tk|৳)?\s*(?:\((.*?)\))?$',
    caseSensitive: false,
  );

  static ParserResult parse(List<String> lines) {

    final drafts = <TransactionDraft>[];

    final errors = <ValidationError>[];

    DateTime? currentDate;

    bool multilineMode = false;

    String multilineBuffer = '';

    TransactionDraft? lastDraft;

    int txIndex = 0;

    for (final line in lines) {

      // ================= MULTILINE =================

      if (line == '"""') {

        multilineMode = !multilineMode;

        if (!multilineMode && lastDraft != null) {

          lastDraft.note = multilineBuffer.trim();

          multilineBuffer = '';
        }

        continue;
      }

      if (multilineMode) {

        multilineBuffer += '$line\n';

        continue;
      }

      // ================= DATE =================

      final dateMatch = dateRegex.firstMatch(line);

      if (dateMatch != null) {

        int d = int.parse(dateMatch.group(1)!);

        int m = int.parse(dateMatch.group(2)!);

        int y = int.parse(dateMatch.group(3)!);

        if (y < 100) {
          y += 2000;
        }

        try {
          currentDate = DateTime(y, m, d);
        }
        catch (_) {
          errors.add(
            ValidationError(
              transactionIndex: txIndex,
              type: ValidationErrorType.invalidDate,
              message: 'Invalid date: $line',
            ),
          );
        }

        continue;
      }

      // ================= TRANSACTION =================

      final txMatch = txRegex.firstMatch(line);

      if (txMatch == null) {

        errors.add(
          ValidationError(
            transactionIndex: txIndex,
            type: ValidationErrorType.invalidSyntax,
            message: 'Invalid transaction syntax: $line',
          ),
        );

        continue;
      }

      txIndex++;

      final source = txMatch.group(1)?.trim();

      final rawType = txMatch.group(2)?.trim();

      final amountText = txMatch.group(3)?.trim();

      final category = txMatch.group(4)?.trim();

      TransactionType type = TransactionType.expense;

      if (rawType != null) {

        switch (rawType.toLowerCase()) {
          case 'income':
            type = TransactionType.income;
            break;

          case 'expense':
            type = TransactionType.expense;
            break;

          case 'debt':
          case 'borrow':
            type = TransactionType.debtBorrow;
            break;

          case 'repay':
            type = TransactionType.debtRepay;
            break;
        }
      }

      final amount = double.tryParse(amountText ?? '');

      final draft = TransactionDraft(
        index: txIndex,
        rawLine: line,
        date: currentDate,
        source: source,
        type: type,
        amount: amount,
        category: category,
      );

      drafts.add(draft);

      lastDraft = draft;
    }

    if (multilineMode) {

      errors.add(
        ValidationError(
          transactionIndex: txIndex,
          type: ValidationErrorType.multilineNotClosed,
          message: 'Multiline note was not closed properly',
        ),
      );
    }

    return ParserResult(
      drafts: drafts,
      errors: errors,
    );
  }
}

