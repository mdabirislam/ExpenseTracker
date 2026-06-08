import '../models/parsed_line.dart';
import 'parse_context.dart';

class LineParser {
  static final RegExp dateRegex =
      RegExp(r'^(\d{1,2})[-/.](\d{1,2})[-/.](\d{2,4})$');

  static final RegExp numberRegex =
      RegExp(r'(\d+(?:\.\d+)?)');

  static ParsedLine? parse(String line, ParseContext ctx) {
    // ---------------- DATE ----------------
    final dateMatch = dateRegex.firstMatch(line);
    if (dateMatch != null) {
      int d = int.parse(dateMatch.group(1)!);
      int m = int.parse(dateMatch.group(2)!);
      int y = int.parse(dateMatch.group(3)!);
      if (y < 100) y += 2000;

      ctx.setDate(DateTime(y, m, d));
      return null;
    }

    // ---------------- GROUP ----------------
    if (line.contains('=>')) {
      ctx.setGroup(line.replaceAll('=>', '').trim());
      return null;
    }

    // ---------------- ITEM ----------------
    if (!line.contains('-')) return null;

    final idx = line.indexOf('-');

    final source = line.substring(0, idx).trim();
    final right = line.substring(idx + 1).trim();

    final noteMatch = RegExp(r'\((.*?)\)').firstMatch(right);
    final note = noteMatch?.group(1);

    final cleaned = right.replaceAll(RegExp(r'\(.*?\)'), '');

    return ParsedLine(
      source: source,
      raw: cleaned,
      note: note,
    );
  }

  static double extractAmount(String text) {
    final matches = numberRegex.allMatches(text).toList();
    if (matches.isEmpty) return 0;
    return double.parse(matches.last.group(1)!);
  }
}