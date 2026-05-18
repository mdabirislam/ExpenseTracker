import '../models/parsed_transaction.dart';
import '../models/transaction_type.dart';

import '../data/local/category_manager.dart';

import 'semantic_engine.dart';
import 'confidence_engine.dart';

class ParseTransactionsService {

  static final RegExp dateRegex =
      RegExp(
    r'^(\d{1,2})[-/.](\d{1,2})[-/.](\d{2,4})$',
  );

  static Future<List<ParsedTransaction>> parse(
    String text,
  ) async {

    final List<ParsedTransaction> result = [];

    final lines = text
        .split('\n')
        .map((e) => e.trim())
        .toList();

    DateTime currentDate = DateTime.now();

    ParsedTransaction? lastTransaction;

    bool multilineMode = false;

    String multilineBuffer = '';

    for (String raw in lines) {

      final line = raw.trim();

      if (line.isEmpty) continue;

      // ================= DATE =================

      final dateMatch =
          dateRegex.firstMatch(line);

      if (dateMatch != null) {

        int d =
            int.parse(dateMatch.group(1)!);

        int m =
            int.parse(dateMatch.group(2)!);

        int y =
            int.parse(dateMatch.group(3)!);

        if (y < 100) {
          y += 2000;
        }

        currentDate = DateTime(y, m, d);

        continue;
      }

      // ================= MULTILINE START =================

      if (line == '"""') {

        multilineMode = !multilineMode;

        if (!multilineMode) {

          if (lastTransaction != null) {

            final updated =
                lastTransaction.copyWith(
              note: multilineBuffer.trim(),
            );

            result[result.length - 1] =
                updated;

            lastTransaction = updated;
          }

          multilineBuffer = '';
        }

        continue;
      }

      // ================= MULTILINE CONTENT =================

      if (multilineMode) {

        multilineBuffer += '$line\n';

        continue;
      }

      // ================= SINGLE LINE NOTE =================

      if (line.startsWith('"') &&
          line.endsWith('"')) {

        final note = line
            .substring(1, line.length - 1)
            .trim();

        if (lastTransaction != null) {

          final updated =
              lastTransaction.copyWith(
            note: note,
          );

          result[result.length - 1] =
              updated;

          lastTransaction = updated;
        }

        continue;
      }

      // ================= TRANSACTION =================

      final tx = _parseTransaction(
        line,
        currentDate,
      );

      result.add(tx);

      lastTransaction = tx;
    }

    return result;
  }

  static ParsedTransaction _parseTransaction(
    String line,
    DateTime date,
  ) {

    final split = line.split('-');

    final left = split.first.trim();

    final right =
        split.sublist(1).join('-').trim();

    // ================= SOURCE + TYPE =================

    String source = left;

    TransactionType? explicitType;

    final leftBracket =
        RegExp(r'^(.*?)\((.*?)\)$')
            .firstMatch(left);

    if (leftBracket != null) {

      source =
          leftBracket.group(1)!.trim();

      final rawType =
          leftBracket.group(2)!.trim();

      explicitType =
          SemanticEngine
              .detectExplicitType(
        rawType,
      );
    }

    // ================= AMOUNT =================

    double amount = 0;

    final amountMatch =
        RegExp(r'(\d[\d,]*\.?\d*)')
            .firstMatch(right);

    if (amountMatch != null) {

      amount = double.tryParse(
            amountMatch.group(1)!
                .replaceAll(',', ''),
          ) ??
          0;
    }

    // ================= CATEGORY =================

    String? explicitCategory;

    final allBrackets =
        RegExp(r'\((.*?)\)')
            .allMatches(right)
            .toList();

    if (allBrackets.isNotEmpty) {

      explicitCategory =
          allBrackets.last.group(1)
              ?.trim()
              .toLowerCase();
    }

    // ================= FINAL TYPE =================

    final finalType =
        explicitType ??
            SemanticEngine.guessType(
              source,
            );

    // ================= CATEGORY VALIDATION =================

    final categories =
        CategoryManager
            .getCategories(finalType)
            .map((e) => e.toLowerCase())
            .toList();

    bool categoryExists = false;

    if (explicitCategory != null) {

      categoryExists =
          categories.contains(
        explicitCategory,
      );
    }

    // ================= FINAL CATEGORY =================

    String finalCategory;

    String? unknownCategory;

    if (categoryExists) {

      finalCategory =
          explicitCategory!;
    }

    else {

      unknownCategory =
          explicitCategory;

      finalCategory =
          SemanticEngine.guessCategory(
        source,
        finalType,
      );
    }

    return ParsedTransaction(
      source: source,

      amount: amount,

      note: null,

      category: finalCategory,

      type: finalType,

      date: date,

      categoryConfidence:
          categoryExists,

      typeConfidence:
          ConfidenceEngine.high(
        explicitType != null,
      ),

      typeGuessed:
          explicitType == null,

      categoryGuessed:
          !categoryExists,

      unknownCategory:
          unknownCategory,
    );
  }
}