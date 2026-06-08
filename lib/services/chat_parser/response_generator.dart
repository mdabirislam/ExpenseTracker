// import '../../models/parser_result.dart';

class ResponseGenerator {

  static String generateErrorMessage(result) {

    if (result.errors.isEmpty) return "";

    final buffer = StringBuffer();

    buffer.writeln("❌ Found errors:");

    for (final e in result.errors) {
      buffer.writeln("- ${e.message}");
    }

    buffer.writeln("\nPlease fix and resend.");

    return buffer.toString();
  }

  static String generateSuccessMessage(result) {

    return "✅ ${result.drafts.length} transactions ready to save";
  }
}