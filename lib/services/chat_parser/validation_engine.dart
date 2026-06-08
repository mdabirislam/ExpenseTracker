import '../../data/local/category_manager.dart';
import '../../models/validation_error.dart';
import '../../models/transaction_draft.dart';

class ValidationEngine {

  static List<ValidationError> validate(
    List<TransactionDraft> drafts,
  ) {

    final errors = <ValidationError>[];

    for (final tx in drafts) {

      // ================= DATE =================

      if (tx.date == null) {

        errors.add(
          ValidationError(
            transactionIndex: tx.index,
            type: ValidationErrorType.invalidDate,
            message: 'Missing date',
          ),
        );
      }

      // ================= SOURCE =================

      if (tx.source == null || tx.source!.isEmpty) {

        errors.add(
          ValidationError(
            transactionIndex: tx.index,
            type: ValidationErrorType.missingSource,
            message: 'Source is empty',
          ),
        );
      }

      // ================= AMOUNT =================

      if (tx.amount == null || tx.amount! <= 0) {

        errors.add(
          ValidationError(
            transactionIndex: tx.index,
            type: ValidationErrorType.invalidAmount,
            message: 'Invalid amount',
          ),
        );
      }

      // ================= CATEGORY =================

      if (tx.category != null) {

        final categories =
            CategoryManager
                .getCategories(tx.type!)
                .map((e) => e.toLowerCase())
                .toList();

        if (!categories.contains(tx.category!.toLowerCase())) {

          errors.add(
            ValidationError(
              transactionIndex: tx.index,
              type: ValidationErrorType.invalidCategory,
              message: 'Unknown category: ${tx.category}',
            ),
          );
        }
      }
    }

    return errors;
  }
}

