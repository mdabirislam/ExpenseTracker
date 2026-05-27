import 'parser_result.dart';

class ChatResponseGenerator {

  static String generate(ParserResult result) {

    if (result.hasErrors) {
      final buffer = StringBuffer();
      buffer.writeln("❌ Errors found:");

      for (final e in result.errors) {
        buffer.writeln("- ${e.message}");
      }

      buffer.writeln("\nPlease fix and resend.");
      return buffer.toString();
    }

    return "✅ Parsed ${result.transactions.length} transactions successfully.";
  }
}