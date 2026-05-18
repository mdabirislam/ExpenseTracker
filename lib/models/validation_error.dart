enum ValidationErrorType {
  invalidDate,
  missingSource,
  invalidAmount,
  invalidType,
  invalidCategory,
  multilineNotClosed,
  orphanNote,
  invalidSyntax,
}

class ValidationError {
  final int transactionIndex;

  final ValidationErrorType type;

  final String message;

  ValidationError({
    required this.transactionIndex,
    required this.type,
    required this.message,
  });
}

