import 'transaction_type.dart';

class ParsedTransaction {

  final String source;

  final double amount;

  final String? note;

  final String category;

  final TransactionType type;

  final DateTime date;

  final bool categoryConfidence;

  final bool typeConfidence;

  final bool typeGuessed;

  final bool categoryGuessed;

  // ✅ NEW
  final String? unknownCategory;

  ParsedTransaction({
    required this.source,
    required this.amount,
    required this.note,
    required this.category,
    required this.type,
    required this.date,
    required this.categoryConfidence,
    required this.typeConfidence,
    required this.typeGuessed,
    required this.categoryGuessed,

    this.unknownCategory,
  });

  ParsedTransaction copyWith({
    String? source,
    double? amount,
    String? note,
    String? category,
    TransactionType? type,
    DateTime? date,
    bool? categoryConfidence,
    bool? typeConfidence,
    bool? typeGuessed,
    bool? categoryGuessed,

    String? unknownCategory,
  }) {

    return ParsedTransaction(
      source: source ?? this.source,

      amount: amount ?? this.amount,

      note: note ?? this.note,

      category: category ?? this.category,

      type: type ?? this.type,

      date: date ?? this.date,

      categoryConfidence:
          categoryConfidence ??
              this.categoryConfidence,

      typeConfidence:
          typeConfidence ??
              this.typeConfidence,

      typeGuessed:
          typeGuessed ??
              this.typeGuessed,

      categoryGuessed:
          categoryGuessed ??
              this.categoryGuessed,

      unknownCategory:
          unknownCategory ??
              this.unknownCategory,
    );
  }
}