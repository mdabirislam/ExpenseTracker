  import '../models/transaction_type.dart';
import 'validation_error.dart';

class TransactionDraft {
  final int index;

  DateTime? date;

  String? source;

  TransactionType? type;

  double? amount;

  String? category;

  String? note;

  String rawLine;

  List<ValidationError> errors;

  TransactionDraft({
    required this.index,
    required this.rawLine,
    this.date,
    this.source,
    this.type,
    this.amount,
    this.category,
    this.note,
    List<ValidationError>? errors,
  }) : errors = errors ?? [];

  bool get hasErrors => errors.isNotEmpty;
}

